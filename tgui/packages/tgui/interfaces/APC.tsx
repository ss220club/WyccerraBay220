import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import {
  Section,
  Box,
  Button,
  BlockQuote,
  LabeledList,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';

export type APCData = {
  locked: BooleanLike;
  isOperating: BooleanLike;
  externalPower: BooleanLike;
  chargeMode: BooleanLike;
  chargingStatus: BooleanLike;
  coverLocked: BooleanLike;
  siliconUser: BooleanLike;
  pChan_Off: number;
  pChan_Off_T: number;
  pChan_Off_A: number;
  pChan_On: number;
  pChan_On_A: number;
  powerCellStatus: number;
  totalLoad: number;
  totalCharging: number;
  failTime: number;
  powerChannels: PowerChannel[];
};

type PowerChannel = {
  title: string;
  powerLoad: number;
  status: number;
};

export const APC = (props, context) => {
  const { act, data } = useBackend<APCData>(context);

  return (
    <Window width={500} height={500} theme="hephaestus">
      <Window.Content scrollable>
        {data.failTime > 0 ? <FailWindow /> : <APCWindow />}
      </Window.Content>
    </Window>
  );
};

export const FailWindow = (props, context) => {
  const { act, data } = useBackend<APCData>(context);

  return (
    <Section
      title="SYSTEM FAILURE"
      buttons={
        <Button
          content="Reboot Now"
          icon="sync"
          color="bad"
          onClick={() => act('reboot')}
        />
      }
    >
      <Box color="red">
        I/O regulator malfuction detected! Waiting for system reboot...
      </Box>
      <BlockQuote>Automatic reboot in {data.failTime} seconds...</BlockQuote>
    </Section>
  );
};

export const APCWindow = (props, context) => {
  const { act, data } = useBackend<APCData>(context);
  return (
    <Window width={500} height={500} theme="hephaestus">
      <Window.Content scrollable>
        <Section fill scrollable title="Power Status" />
      </Window.Content>
    </Window>
  );
};
