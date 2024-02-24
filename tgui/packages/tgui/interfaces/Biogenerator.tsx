import { BooleanLike } from '../../common/react';
import { capitalizeAll } from 'common/string';
import { useBackend } from '../backend';
import {
  Button,
  Section,
  Stack,
  Collapsible,
  Icon,
  LabeledList,
  ProgressBar,
  Dimmer,
} from '../components';
import { Window } from '../layouts';

type BiogenData = {
  processing: BooleanLike;
  storedPlants: BooleanLike;
  container: BooleanLike;
  containerContent: number;
  containerMaxContent: number;
  biomass: number;
  types: BiogenType[];
};

type BiogenType = {
  type_name: string;
  products: BiogenList[];
};

type BiogenList = {
  name: string;
  cost: number;
  product_index: number;
};

export const Biogenerator = (props, context) => {
  const { act, data } = useBackend<BiogenData>(context);
  const {
    biomass,
    container,
    containerContent,
    containerMaxContent,
    processing,
    storedPlants,
  } = data;
  return (
    <Window width={400} height={600} title="Биогенератор">
      <Window.Content>
        {!!processing && <BiogenProcessing />}
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Статус">
              <LabeledList>
                <LabeledList.Item label="Биомасса">
                  {biomass} <Icon name="leaf" color="green" size={1.2} />
                </LabeledList.Item>
                <LabeledList.Item label="Ёмкость">
                  <ProgressBar
                    value={containerContent}
                    maxValue={containerMaxContent}
                  >
                    {container ? (
                      <Stack.Item textAlign="center">
                        {containerContent +
                          ' / ' +
                          containerMaxContent +
                          ' юнитов'}
                      </Stack.Item>
                    ) : (
                      <Stack.Item textAlign="center">
                        Ёмкость отсутствует
                      </Stack.Item>
                    )}
                  </ProgressBar>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Управление">
              <Stack textAlign="center">
                <Stack.Item grow basis="30%">
                  <Button
                    fluid
                    icon="power-off"
                    disabled={!storedPlants}
                    content="Включить"
                    onClick={() => act('activate')}
                  />
                </Stack.Item>
                <Stack.Item grow basis="40%">
                  <Button
                    fluid
                    icon="bucket"
                    disabled={!container}
                    content="Достать контейнер"
                    onClick={() => act('detach')}
                  />
                </Stack.Item>
                <Stack.Item grow basis="30%">
                  <Button
                    fluid
                    icon="eject"
                    disabled={!storedPlants}
                    content="Извлечь"
                    onClick={() => act('eject_plants')}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Продукты">
              {container ? <BiogenProducts /> : <BiogenNoBeaker />}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BiogenProducts = (props, context) => {
  const { act, data } = useBackend<BiogenData>(context);
  return (
    <>
      {data.types.map((type, typeIndex) => (
        <Collapsible key={typeIndex} title={type.type_name} open>
          {type.products.map((product, productIndex) => (
            <Stack
              key={productIndex}
              py="2px"
              className="candystripe"
              align="center"
            >
              <Stack.Item basis="70%" ml="2px">
                {capitalizeAll(product.name)}
              </Stack.Item>
              <Stack.Item textAlign="right" basis="20%">
                {product.cost} <Icon name="leaf" color="good" size={1.2} />
              </Stack.Item>
              <Stack.Item basis="6%">
                <Button
                  fluid
                  icon="angle-down"
                  disabled={product.cost > data.biomass}
                  onClick={() =>
                    act('create', {
                      type: type.type_name,
                      product_index: productIndex + 1,
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          ))}
        </Collapsible>
      ))}
    </>
  );
};

const BiogenNoBeaker = () => {
  return (
    <Stack fill bold textAlign="center">
      <Stack.Item grow fontSize={1.5} align="center" color="label">
        <Icon.Stack>
          <Icon size={5} name="bucket" color="blue" />
          <Icon size={5} name="slash" color="red" />
        </Icon.Stack>
        <br />
        Отсутствует ёмкость
      </Stack.Item>
    </Stack>
  );
};

const BiogenProcessing = () => {
  return (
    <Dimmer>
      <Stack fill textAlign="center">
        <Stack.Item bold color="label">
          <Icon name="spinner" color="white" size={5} mb={5} spin />
          <br />
          Биогенератор работает...
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
