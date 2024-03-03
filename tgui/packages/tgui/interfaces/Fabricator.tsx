import { BooleanLike } from 'common/react';
import { capitalize, capitalizeAll } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  Box,
  Button,
  NoticeBox,
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
  image: string;
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
  name: string;
  hidden: BooleanLike;
  category: string;
  reference: string;
  image: string;
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
    <Window width={780} height={545}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="25%">
            <Stack fill vertical>
              <Stack.Item grow>
                <FabCategories />
              </Stack.Item>
              <Stack.Item m={0}>
                <FabFilters />
              </Stack.Item>
              <Stack.Item textAlign="center">
                <NoticeBox color="blue">
                  Результаты поиска зависят от выбранной категории
                </NoticeBox>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item basis="50%">
            <FabDesigns />
          </Stack.Item>
          <Stack.Item basis="25%">
            <Stack fill vertical>
              <Stack.Item>
                <FabResources />
              </Stack.Item>
              <Stack.Item grow>
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
      <Tabs vertical textAlign="center">
        <Tabs.Tab
          height={3}
          selected={'All' === tab}
          onClick={() => setTab('All')}
        >
          All
        </Tabs.Tab>
        {data.categories.map((category) => (
          <Tabs.Tab
            mt={1}
            height={3}
            color="blue"
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

const FabFilters = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'All');
  const [hideUnavailable, setHideUnavailable] = useSharedState(
    context,
    'hideUnavailable',
    false
  );
  const [compactMode, setCompactMode] = useSharedState(
    context,
    'compactMode',
    false
  );
  return (
    <Section>
      <Button.Checkbox
        fluid
        checked={compactMode}
        content={'Компактный режим'}
        onClick={() => setCompactMode(!compactMode)}
      />
      <Button.Checkbox
        fluid
        checked={hideUnavailable}
        content={'Скрыть недоступное'}
        onClick={() => setHideUnavailable(!hideUnavailable)}
      />
    </Section>
  );
};

const FabDesigns = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [tab] = useLocalState(context, 'tab', 'All');
  const [hideUnavailable] = useLocalState(context, 'hideUnavailable', '');
  const [compactMode] = useLocalState(context, 'compactMode', '');

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
          {filteredRecipes.map((recipe) =>
            hideUnavailable && !checkResourcesAvailability(recipe) ? null : (
              <ImageButton
                bold={compactMode ? true : false}
                image={recipe.image}
                imageSize={compactMode ? '32px' : '64px'}
                key={recipe.reference}
                title={compactMode ? '' : capitalizeAll(recipe.name)}
                content={
                  compactMode
                    ? capitalizeAll(recipe.name)
                    : getRequiredResources(recipe)
                }
                tooltip={compactMode ? getRequiredResources(recipe) : ''}
                color={recipe.hidden && 'brown'}
                disabled={!checkResourcesAvailability(recipe)}
                onClick={() =>
                  act('make', { make: recipe.reference, multiplier: 1 })
                }
              />
            )
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FabResources = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { material_storage } = data;
  return (
    <Section fill title="Ресурсы">
      {material_storage.map((material) => (
        <ImageButton
          image={material.image}
          imageSize={'58px'}
          mb={0}
          height="57px"
          key={material.name}
          title={capitalizeAll(material.name)}
          selected={material.stored === material.max}
          content={
            <ProgressBar
              color="grey"
              value={material.stored}
              minValue={0}
              maxValue={material.max}
            >
              {material.stored}
            </ProgressBar>
          }
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
          <Stack.Item grow fontSize={1.25} align="center" color="label">
            <Icon.Stack mb={-5}>
              <Icon size={4} name="bars" color="gray" />
              <Icon size={4} name="slash" color="red" />
            </Icon.Stack>
            <br />
            Очередь пуста
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
