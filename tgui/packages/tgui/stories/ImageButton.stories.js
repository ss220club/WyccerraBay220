import { useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  ImageButton,
  Input,
  Slider,
  Section,
  Stack,
} from '../components';

export const meta = {
  title: 'ImageButton',
  render: () => <Story />,
};

const COLORS_SPECTRUM = [
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'gold',
];

const COLORS_STATES = ['good', 'average', 'bad', 'black', 'white'];

const Story = (props, context) => {
  const [disabled, setDisabled] = useLocalState(context, 'disabled', false);
  const [vertical1, setVertical1] = useLocalState(context, 'vertical1', true);
  const [vertical2, setVertical2] = useLocalState(context, 'vertical2', true);
  const [vertical3, setVertical3] = useLocalState(context, 'vertical3', false);
  const [title, setTitle] = useLocalState(context, 'title', 'Image Button');
  const [content, setContent] = useLocalState(
    context,
    'content',
    'Image is a LIE!'
  );
  const [itemContent, setItemContent] = useLocalState(
    context,
    'itemContent',
    'Second Button'
  );
  const [itemIcon, setItemIcon] = useLocalState(
    context,
    'itemIcon',
    'face-smile'
  );

  const [imageSize, setImageSize] = useLocalState(context, 'imageSize', 64);

  const toggleVertical1 = () => {
    setVertical1(!vertical1);
  };

  const toggleVertical2 = () => {
    setVertical2(!vertical2);
  };

  const toggleVertical3 = () => {
    setVertical3(!vertical3);
  };

  const toggleDisabled = () => {
    setDisabled(!disabled);
  };

  return (
    <>
      <Section>
        <Stack>
          <Stack.Item basis="50%">
            <LabeledList>
              <LabeledList.Item label="Title">
                <Input value={title} onInput={(e, value) => setTitle(value)} />
              </LabeledList.Item>
              <LabeledList.Item label="Content">
                <Input
                  value={content}
                  onInput={(e, value) => setContent(value)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Image Size">
                <Slider
                  animated
                  width={10}
                  value={imageSize}
                  minValue={0}
                  maxValue={256}
                  step={1}
                  stepPixelSize={2}
                  onChange={(e, value) => setImageSize(value)}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item basis="50%">
            <LabeledList>
              <LabeledList.Item label="Item Content">
                <Input
                  value={itemContent}
                  onInput={(e, value) => setItemContent(value)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Item Icon">
                <Input
                  value={itemIcon}
                  onInput={(e, value) => setItemIcon(value)}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Vertical">
                <Button.Checkbox
                  fluid
                  content="Vertical"
                  checked={vertical3}
                  onClick={toggleVertical3}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
        <ImageButton
          mt={vertical3 ? 1 : 0}
          width={vertical3 && `${imageSize}px`}
          ellipsis={vertical3}
          vertical={vertical3}
          disabled={disabled}
          title={title}
          content={content}
          tooltip={
            vertical3
              ? content
              : 'Just imagine that all the buttons have images'
          }
          imageSize={`${imageSize}px`}
        >
          {!vertical3 && (
            <ImageButton.Item
              bold
              width={'64px'}
              selected={disabled}
              content={itemContent}
              tooltip="Click to disable main button"
              tooltipPosition="bottom-end"
              icon={itemIcon}
              iconColor={'gold'}
              iconSize={2}
              onClick={toggleDisabled}
            />
          )}
        </ImageButton>
      </Section>
      <Section
        title="Color States"
        buttons={
          <Button.Checkbox
            content="Vertical"
            checked={vertical1}
            onClick={toggleVertical1}
          />
        }
      >
        {COLORS_STATES.map((color) => (
          <ImageButton
            m={vertical1 ? 0.5 : 0}
            vertical={vertical1}
            key={color}
            color={color}
            content={color}
            imageSize={vertical1 ? '48px' : '24px'}
          />
        ))}
      </Section>
      <Section
        title="Available Colors"
        buttons={
          <Button.Checkbox
            content="Vertical"
            checked={vertical2}
            onClick={toggleVertical2}
          />
        }
      >
        {COLORS_SPECTRUM.map((color) => (
          <ImageButton
            m={vertical2 ? 0.5 : 0}
            vertical={vertical2}
            key={color}
            color={color}
            content={color}
            imageSize={vertical2 ? '48px' : '24px'}
          />
        ))}
      </Section>
    </>
  );
};
