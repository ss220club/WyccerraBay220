import { BooleanLike } from 'common/react';
import { capitalize, capitalizeAll } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Input,
  Icon,
  Tabs,
  ImageButton,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';

export type FabricatorData = {
  functional: BooleanLike;
  material_efficiency: number;
  categories: string[];
  material_storage: Material[];
  current_build: Build;
  build_queue: Queue[];
  recipes: Recipe[];
};

type Material = {
  refundable: BooleanLike;
  name: string;
  stored: number;
  max: number;
  units_per_sheet: number;
};

type Build = {
  name: string;
  multiplier: number;
  progress: number;
};

type Queue = {
  name: string;
  multiplier: number;
  reference: string;
};

type Recipe = {
  hidden: BooleanLike;
  name: string;
  category: string;
  reference: string;
  cost: Cost[];
};

type Cost = {
  name: BooleanLike;
  amount: number;
  units_per_sheet: number;
};

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis="25%">
            <Stack fill vertical>
              <Stack.Item grow>
                <FabCategories />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis="50%">
            <FabDesigns />
          </Stack.Item>
          <Stack.Item grow basis="25%">
            <Stack fill vertical>
              <Stack.Item grow basis="53%">
                <FabResources />
              </Stack.Item>
              <Stack.Item grow basis="47%">
                <FabQueue />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const FabCategories = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'All');
  return (
    <Section fill scrollable title="Категории">
      <Tabs vertical>
        <Tabs.Tab selected={'All' === tab} onClick={() => setTab('All')}>
          All
        </Tabs.Tab>
        {data.categories.map((category) => (
          <Tabs.Tab
            selected={category === tab}
            key={category}
            onClick={() => setTab(category)}
          >
            {category}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const FabDesigns = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [tab, setTab] = useLocalState(context, 'tab', 'All');
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const filteredRecipes = data.recipes
    .filter(
      (recipe) =>
        (tab === 'All' || recipe.category === tab) &&
        recipe.name.toLowerCase().includes(searchText.toLowerCase())
    )
    .sort((a, b) => a.name.localeCompare(b.name));

  const getRequiredResources = (recipe) => {
    const requiredResources = recipe.cost.map(
      (cost) => `${capitalize(cost.name)} x${cost.amount}`
    );
    return requiredResources.join(' | ');
  };

  const checkResourcesAvailability = (recipe) => {
    for (const cost of recipe.cost) {
      const material = data.material_storage.find(
        (mat) => mat.name === cost.name
      );
      if (!material || material.stored < cost.amount) {
        return false;
      }
    }
    return true;
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          mt={0.75}
          width="100%"
          placeholder="Поиск рецептов..."
          value={searchText}
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={`Рецепты - ${tab}`} textAlign="center">
          {filteredRecipes.map((recipe) => (
            <ImageButton
              key={recipe.reference}
              title={capitalizeAll(recipe.name)}
              content={getRequiredResources(recipe)}
              color={recipe.hidden && 'brown'}
              disabled={!checkResourcesAvailability(recipe)}
              onClick={() =>
                act('make', { make: recipe.reference, multiplier: 1 })
              }
            />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FabResources = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { material_storage } = data;
  return (
    <Section fill scrollable title="Ресурсы">
      {material_storage.map((material) => (
        <ImageButton
          key={material.name}
          title={capitalizeAll(material.name)}
          content={`${material.stored} / ${material.max}`}
          selected={material.stored === material.max}
          disabled={!material.stored}
          onClick={() => act('eject_mat', { eject_mat: material.name })}
        />
      ))}
    </Section>
  );
};

const FabQueue = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { current_build } = data;
  return (
    <Section fill scrollable title="Очередь">
      {current_build ? (
        <Stack vertical>
          <Stack.Item>
            {current_build && (
              <ProgressBar
                value={current_build.progress}
                minValue={0}
                maxValue={100}
              >
                <Box textAlign="center">
                  {capitalizeAll(current_build.name)}
                </Box>
              </ProgressBar>
            )}
          </Stack.Item>
          <Stack.Divider />
          {data.build_queue.map((item, index) => (
            <Stack.Item key={index}>
              <Stack>
                <Stack.Item grow>
                  <ProgressBar
                    value={item.multiplier}
                    minValue={0}
                    maxValue={item.reference}
                  >
                    <Box textAlign="center">{capitalizeAll(item.name)}</Box>
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="times"
                    color="red"
                    onClick={() => act('cancel', { cancel: item.reference })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          ))}
        </Stack>
      ) : (
        <Stack fill bold textAlign="center">
          <Stack.Item grow fontSize={1.5} align="center" color="label">
            <Icon.Stack>
              <Icon size={5} name="bars" color="gray" />
              <Icon size={5} name="slash" color="red" />
            </Icon.Stack>
            <br />
            Очередь пуста
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
