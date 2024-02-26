import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Input, Tabs } from '../components';
import { Window } from '../layouts';

type FabricatorData = {
  category: string;
  categories: string[];
};

export const Fabricator = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  const { category } = data;
  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow basis="25%">
            <Stack fill vertical>
              <Stack.Item>
                <Input width="100%" />
              </Stack.Item>
              <Stack.Item grow>
                <FabCategories />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis="55%">
            <FabDesigns />
          </Stack.Item>
          <Stack.Item grow basis="20%">
            <Stack fill vertical>
              <Stack.Item grow basis="35%">
                <FabResources />
              </Stack.Item>
              <Stack.Item grow basis="65%">
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
  const [tab, setTab] = useLocalState(context, 'tab', 'All');
  return (
    <Section fill scrollable title="Категории">
      <Tabs vertical>
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
  return (
    <Section fill scrollable title="Рецепты">
      Дезигны
    </Section>
  );
};

const FabResources = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  return (
    <Section fill scrollable title="Ресурсы">
      Ресурсы внутри
    </Section>
  );
};

const FabQueue = (props, context) => {
  const { act, data } = useBackend<FabricatorData>(context);
  return (
    <Section fill scrollable title="Очередь">
      Очередь крафта
    </Section>
  );
};
