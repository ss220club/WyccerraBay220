import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Button,
  Section,
  NumberInput,
  LabeledList,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';

type Data = {
  on: BooleanLike;
  pressure_set: number;
  max_pressure: number;
  last_flow_rate: number;
  last_power_draw: number;
  max_power_draw: number;
};

export const Pump = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    on,
    pressure_set,
    max_pressure,
    last_flow_rate,
    last_power_draw,
    max_power_draw,
  } = data;

  return (
    <Window width={330} height={200}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Питание">
              <Button
                icon={on ? 'power-off' : 'power-off'}
                content={on ? 'Включено' : 'Отключено'}
                color={on ? null : 'red'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Давление">
              <Button
                icon="fast-backward"
                textAlign="center"
                disabled={pressure_set === 0}
                width={2.2}
                onClick={() => act('min')}
              />
              <NumberInput
                animated
                unit="kPa"
                width={6.1}
                lineHeight={1.5}
                minValue={0}
                maxValue={max_pressure}
                value={pressure_set}
                step={10}
                onDrag={(e, value) =>
                  act('set', {
                    rate: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                textAlign="center"
                disabled={pressure_set === 0}
                width={2.2}
                onClick={() => act('max')}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Нагрузка">
              <ProgressBar
                ranges={{
                  bad: [-Infinity, 0],
                  average: [0, 99],
                  good: [99, Infinity],
                }}
                value={last_power_draw}
                minValue={0}
                maxValue={max_power_draw}
              />
            </LabeledList.Item>
            <LabeledList.Item color={'gray'}>
              Текущее потребление = {last_power_draw} W
              <LabeledList.Divider />
              Макс. потребление = {max_power_draw} W
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
