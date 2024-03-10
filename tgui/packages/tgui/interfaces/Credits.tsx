import { useBackend } from '../backend';
import {
  Button,
  BlockQuote,
  Divider,
  LabeledList,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type CreditsData = {
  credits: Credit[];
};

type Credit = {
  name: string;
  coders: string[];
  mappers: string[];
  spriters: string[];
  ui_designers: string[];
  special: string[];
  linkContributors: string;
};

export const Credits = (props, context) => {
  const { act, data } = useBackend<CreditsData>(context);
  return (
    <Window width={500} height={700}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack fill vertical textAlign="center">
                <Stack.Item fontSize={2.5} bold>
                  Sierra SS13
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        fluid
                        color="blue"
                        content={'GitHub'}
                        onClick={() => act('openGitHub')}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        color="blue"
                        content={'Wiki'}
                        onClick={() => act('openWiki')}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        color="blue"
                        content={'Discord'}
                        onClick={() => act('openDiscord')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item mt={2}>
                  <BlockQuote color="gray">
                    Разработка - сложная и часто наблагодарная работа,
                    заставляющая человека испытывать стресс от различных
                    факторов: от непринятия его работы сообществом до споров о
                    том, как ему делать свою работу. Однако, без этих людей ни
                    один проект не может нормально существовать. Здесь мы
                    выражаем нашу благодарность каждому разработчику, что
                    помогал проекту стать лучше в плане написания кода,
                    проектирования карт или рисования спрайтов.
                  </BlockQuote>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>
            <Section
              fill
              scrollable
              style={{ 'background-color': 'rgba(0, 0, 0, 0)' }}
            >
              {data.credits.map((credit) => (
                <Section
                  key={credit.name}
                  title={credit.name}
                  buttons={
                    credit.linkContributors && (
                      <Button
                        fluid
                        content={'Контрибьюторы'}
                        onClick={() =>
                          act('openContributors', {
                            buildPage: credit.linkContributors,
                            buildName: credit.name,
                          })
                        }
                      />
                    )
                  }
                  style={{ 'background-color': 'rgba(0, 0, 0, 0.33)' }}
                >
                  <LabeledList>
                    {credit.coders && (
                      <LabeledList.Item label={'Кодеры'}>
                        {credit.coders.map((coder, index) => (
                          <Stack key={index} inline>
                            {coder},&nbsp;
                          </Stack>
                        ))}
                      </LabeledList.Item>
                    )}
                    {credit.mappers && (
                      <LabeledList.Item label={'Мапперы'}>
                        {credit.mappers.map((mapper, index) => (
                          <Stack key={index} inline>
                            {mapper},&nbsp;
                          </Stack>
                        ))}
                      </LabeledList.Item>
                    )}
                    {credit.spriters && (
                      <LabeledList.Item label={'Спрайтеры'}>
                        {credit.spriters.map((spriter, index) => (
                          <Stack key={index} inline>
                            {spriter},&nbsp;
                          </Stack>
                        ))}
                      </LabeledList.Item>
                    )}
                    {credit.ui_designers && (
                      <LabeledList.Item label={'UI/UX Дизайнеры'}>
                        {credit.ui_designers.map((ui_designer, index) => (
                          <Stack key={index} inline>
                            {ui_designer},&nbsp;
                          </Stack>
                        ))}
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                  {credit.special && (
                    <Stack.Item mt={3}>
                      <Section
                        textAlign="center"
                        title={'Отдельная благодарность'}
                      >
                        {credit.special.map((spec, index) => (
                          <Stack key={index} inline>
                            {spec},&nbsp;
                          </Stack>
                        ))}
                      </Section>
                    </Stack.Item>
                  )}
                </Section>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
