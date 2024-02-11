import { classes, BooleanLike } from 'common/react';
import { capitalize, capitalizeAll } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Icon,
  Section,
  Stack,
  Tooltip,
  Dimmer,
  NoticeBox,
  LabeledList,
} from '../components';
import { Window } from '../layouts';

export type VendingData = {
  vend_ready: BooleanLike;
  message_err: BooleanLike;
  speaker: BooleanLike;
  panel: BooleanLike;
  mode: BooleanLike;
  product: string;
  image: string;
  price: number;
  coin: string;
  message: string;
  products: Product[];
};

type Product = {
  key: string;
  name: string;
  price: number;
  ammount: number;
  imageID: string;
};

export const Vending = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  return !data.panel ? <VendingMain /> : <VendingMaint />;
};

export const VendingMaint = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { speaker } = data;
  return (
    <Window width={375} height={175}>
      <Window.Content>
        <Stack fill vertical>
          <NoticeBox>Панель открыта, проводится тех. обслуживание.</NoticeBox>
          <Stack.Item grow>
            <Section fill title="Параметры">
              <LabeledList>
                <LabeledList.Item
                  label="Динамик"
                  buttons={
                    <Button
                      content={speaker ? 'On' : 'Off'}
                      selected={speaker}
                      icon={speaker ? 'volume-up' : 'volume-mute'}
                      color={speaker ? '' : 'bad'}
                      onClick={() => act('togglevoice')}
                    />
                  }
                />
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const VendingMain = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  const { coin, vend_ready, products = [] } = data;
  return (
    <Window width={products.length > 25 ? '391' : '375'} height={550}>
      {!vend_ready || data.mode ? <Vend /> : ''}
      <Window.Content>
        <Section
          fill
          scrollable
          title="Продукты"
          buttons={
            coin ? (
              <Button
                content="Достать монетку"
                onClick={() => act('remove_coin')}
              />
            ) : (
              ''
            )
          }
        >
          {products.map((product) => (
            <Tooltip
              key={product.key}
              content={
                <>
                  {<b>{capitalize(product.name)}</b>}
                  <br />
                  <br />
                  (В наличии: {product.ammount})
                </>
              }
            >
              <Stack.Item
                inline
                grow
                className={classes([
                  'Vending__Button',
                  product.ammount <= 0 && 'Vending__Button--disabled',
                ])}
                onClick={() =>
                  product.ammount > 0 && act('vend', { vend: product.key })
                }
              >
                <img
                  src={`data:image/jpeg;base64,${product.imageID}`}
                  style={{
                    width: '64px',
                    '-ms-interpolation-mode': 'nearest-neighbor',
                  }}
                />
                <Stack.Item
                  bold
                  className={classes([
                    'Vending__Price',
                    product.ammount <= 0 && 'Vending__Price--disabled',
                  ])}
                >
                  {product.price > 0 ? product.price : 'Free'}
                </Stack.Item>
              </Stack.Item>
            </Tooltip>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};

const Vend = (props, context) => {
  const { act, data } = useBackend<VendingData>(context);
  return data.mode ? (
    <Dimmer textAlign="center">
      {!data.message_err ? (
        <NoticeBox height="22px" width="378px">
          Для оплаты, проведите картой или вставьте деньги.
        </NoticeBox>
      ) : (
        <NoticeBox height="22px" width="378px" color="bad" fontSize={0.85}>
          {data.message}
        </NoticeBox>
      )}
      <Stack.Item mt={15} color="label">
        <h2>Вы покупаете</h2>
      </Stack.Item>
      <Stack.Item>
        <h1>{capitalizeAll(data.product)}</h1>
      </Stack.Item>
      <img
        src={`data:image/jpeg;base64,${data.image}`}
        style={{
          width: '140px',
          '-ms-interpolation-mode': 'nearest-neighbor',
        }}
      />
      <Stack.Item color="label">
        <h2>К оплате</h2>
      </Stack.Item>
      <Stack.Item>
        <h1>{data.price}$</h1>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          mt={15.5}
          lineHeight={2}
          content={'Отмена'}
          onClick={() => act('cancelpurchase')}
        />
      </Stack.Item>
    </Dimmer>
  ) : (
    <Dimmer textAlign="center">
      <Icon name="smile" size="7" color="yellow" />
      <Stack.Item color="label" mt={5}>
        <h1>Спасибо за покупку!</h1>
      </Stack.Item>
    </Dimmer>
  );
};
