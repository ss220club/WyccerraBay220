import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Button,
  Section,
  ProgressBar,
  Stack,
  ImageButton,
  Icon,
  NumberInput,
  LabeledList,
} from '../components';
import { Window } from '../layouts';

type ChemMasterData = {
  isAnalyzedBlood: BooleanLike;
  isSloppy: BooleanLike;
  container: BooleanLike;
  toBeaker: BooleanLike;
  productionOptions: string;

  pillBottle: BooleanLike;
  pillBottleContent: number;
  pillBottleMaxContent: number;

  analyzedReagent: string;
  analyzedDesc: string;
  analyzedBloodSpecies: string;
  analyzedBloodType: string;
  analyzedBloodDNA: string;

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
  sprite: string;
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
                <ChemMasterSprites />
              </Stack.Item>
              <Stack.Item basis={'50%'}>
                <ChemMasterActions />
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
      <Stack.Item basis={'50%'}>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable title="Ёмкость" textAlign="center">
              {data.container ? (
                <Stack.Item grow>
                  <Stack vertical zebra textAlign="left">
                    {data.containerChemicals.map((reagent) => {
                      const analyzed = data.analyzedReagent === reagent.name;
                      return (
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
                            <Stack.Item ml={0.25}>
                              <Button
                                selected={analyzed}
                                icon={
                                  analyzed
                                    ? 'magnifying-glass-chart'
                                    : 'magnifying-glass'
                                }
                                tooltip={
                                  analyzed ? (
                                    <>
                                      <h4>Анализ - {reagent.name}</h4>
                                      <br />
                                      {data.analyzedDesc}
                                      {data.isAnalyzedBlood && (
                                        <>
                                          <br />
                                          <br />
                                          {data.analyzedBloodSpecies}
                                          <br />
                                          {data.analyzedBloodType}
                                          <br />
                                          {data.analyzedBloodDNA}
                                        </>
                                      )}
                                    </>
                                  ) : (
                                    'Анализировать'
                                  )
                                }
                                onClick={() =>
                                  act('analyze', { name: reagent.ref })
                                }
                              />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                </Stack.Item>
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
          {!!data.container && (
            <Stack.Item mt={0}>
              <Section textAlign="center">
                <Button
                  fluid
                  color={data.bufferChemicals.length > 1 ? 'orange' : ''}
                  content={
                    data.bufferChemicals.length > 0
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
      <Stack.Item basis={'50%'}>
        <Section fill title="Буфер" textAlign="center">
          {data.bufferChemicals.length > 0 ? (
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
                  color={data.toBeaker ? 'good' : 'bad'}
                  content={
                    data.toBeaker ? 'Переливать в ёмкость' : 'Уничтожать'
                  }
                  onClick={() => act('toggle')}
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

const ChemMasterSprites = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Stack fill vertical textAlign="center" height="350px">
      <Stack.Item grow>
        <Section fill scrollable title="Стиль таблеток">
          {data.pillSprites.map(({ id, sprite }) => (
            <ImageButton
              key={id}
              m={0.5}
              asset
              vertical
              selected={data.pillSprite === id}
              imageAsset={'chem_master32x32'}
              image={sprite}
              onClick={() => act('changePillStyle', { style: id })}
            />
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item height="85px">
        <Section fill scrollable title="Стиль бутылок">
          {data.bottleSprites.map(({ id, sprite }) => (
            <ImageButton
              key={id}
              m={0.5}
              asset
              vertical
              selected={data.bottleSprite === id}
              imageAsset={'chem_master32x32'}
              image={sprite}
              onClick={() => act('changeBottleStyle', { style: id })}
            />
          ))}
        </Section>
      </Stack.Item>
      {!!data.pillBottle && (
        <Stack.Item textAlign="center">
          <Section fill title="Таблетница">
            <Stack fill>
              <Stack.Item grow>
                <ProgressBar
                  minValue={0}
                  maxValue={data.pillBottleMaxContent}
                  value={data.pillBottleContent}
                >
                  {data.pillBottleContent} / {data.pillBottleMaxContent}
                </ProgressBar>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  tooltip={'Вынуть таблетницу'}
                  onClick={() => act('ejectPillBottle')}
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ChemMasterActions = (props, context) => {
  const { act, data } = useBackend<ChemMasterData>(context);
  return (
    <Section fill title="Изготовление" textAlign="center">
      <LabeledList>
        <LabeledList.Item label={'1'} />
        <LabeledList.Item label={'2'} />
        <LabeledList.Item label={'3'} />
        <LabeledList.Item label={'4'} />
      </LabeledList>
    </Section>
  );
};
