import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  ProgressBar,
  Stack,
  ImageButton,
  Icon,
  NumberInput,
} from '../components';
import { Window } from '../layouts';

type ChemMasterData = {
  isSloppy: BooleanLike;
  loadedContainer: BooleanLike;
  loadedPillBottle: BooleanLike;
  isTransferringToBeaker: BooleanLike;
  productionOptions: string;
  pillBottleBlurb: string;
  analyzedReagent: string;
  analyzedData: string;
  pillDosage: number;
  bottleDosage: number;
  pillSprite: number;
  bottleSprite: string;
  containerChemicals: Container[];
  bufferChemicals: Buffer[];
  pillSprites: PillSprite[];
  bottleSprites: BottleSprite[];
};

type Container = {
  name: string;
  desc: string;
  volume: number;
  ref: string;
};

type Buffer = {
  name: string;
  desc: string;
  volume: number;
  ref: string;
};

type PillSprite = {
  id: number;
  sprite: number;
};

type BottleSprite = {
  id: string;
  sprite: string;
};

export const ChemMaster = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Window width={555} height={700}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <ChemMasterChemicals />
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item basis={'50%'}>
                <ChemMasterIcons />
              </Stack.Item>
              <Stack.Item basis={'50%'}>
                <ChemMasterPillBottle />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemMasterChemicals = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill>
      <Stack.Item basis="50%">
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable title="Ёмкость" textAlign="center">
              {data.loadedContainer ? (
                <Stack fill vertical>
                  <Stack.Item grow>
                    <Stack vertical zebra textAlign="left">
                      {data.containerChemicals.map((reagent) => (
                        <Stack.Item key={reagent.name} color="label">
                          <Stack fill>
                            <Stack.Item grow>
                              {reagent.volume} units of {reagent.name}
                            </Stack.Item>
                            <Stack.Item>
                              <NumberInput
                                animated
                                value={0}
                                minValue={1}
                                maxValue={reagent.volume}
                                stepPixelSize={5}
                                onChange={(e, value) =>
                                  act('add', {
                                    reagent: reagent.ref,
                                    amount: value,
                                  })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack fill bold textAlign="center">
                  <Stack.Item grow fontSize={1.25} align="center" color="label">
                    <Icon.Stack>
                      <Icon size={5} name="flask" color="blue" />
                      <Icon size={5} name={'slash'} color="red" />
                    </Icon.Stack>
                    <br />
                    Отсутствует ёмкость
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
          {data.loadedContainer && (
            <Stack.Item mt={0}>
              <Section textAlign="center">
                <Button
                  fluid
                  color={data.bufferChemicals.length > 1 ? 'orange' : ''}
                  content={
                    data.bufferChemicals.length > 1
                      ? 'Вынуть ёмкость и очистить буфер'
                      : 'Вынуть ёмкость'
                  }
                  onClick={() => act('eject')}
                />
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Item basis="50%">
        <Section fill title="Буфер" textAlign="center">
          {data.bufferChemicals.length > 1 ? (
            <Stack fill vertical>
              <Stack.Item grow>
                <Stack vertical zebra textAlign="left">
                  {data.bufferChemicals.map((reagent) => (
                    <Stack.Item key={reagent.name} color="label">
                      <Stack fill>
                        <Stack.Item grow>
                          {reagent.volume} units of {reagent.name}
                        </Stack.Item>
                        <Stack.Item>
                          <NumberInput
                            animated
                            value={0}
                            minValue={1}
                            maxValue={reagent.volume}
                            stepPixelSize={5}
                            onChange={(e, value) =>
                              act('remove', {
                                reagent: reagent.ref,
                                amount: value,
                              })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  content={data.productionOptions}
                  onClick={() => act('eject')}
                />
              </Stack.Item>
            </Stack>
          ) : (
            <Stack fill bold textAlign="center">
              <Stack.Item grow fontSize={1.25} align="center" color="label">
                <Icon.Stack>
                  <Icon size={5} name="droplet" />
                  <Icon size={5} name="slash" color="red" />
                </Icon.Stack>
                <br />
                Буфер пуст
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ChemMasterIcons = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill vertical textAlign="center" height="350px">
      <Stack.Item basis="50%">
        <Section fill scrollable title={data.pillSprite}>
          {data.pillSprites.map((pillSprite) => (
            <ImageButton
              key={pillSprite.id}
              m={0.5}
              asset
              vertical
              imageAsset={'chem_master32x32'}
              image={pillSprite.sprite}
              onClick={() =>
                act('changePillStyle', { pillStyle: pillSprite.id })
              }
            />
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item basis="50%">
        <Section fill scrollable title="Стиль бутылок">
          {data.bottleSprites.map((bottleSprite) => (
            <ImageButton
              key={bottleSprite.id}
              m={0.5}
              asset
              vertical
              imageAsset={'chem_master32x32'}
              image={bottleSprite.sprite}
              onClick={() =>
                act('changeBottleStyle', { bottleStyle: bottleSprite.id })
              }
            />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ChemMasterPillBottle = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return <Section fill title="Таблетница" textAlign="center" />;
};
