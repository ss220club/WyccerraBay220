/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { classes, pureComponentHooks } from 'common/react';
import { computeBoxClassName, computeBoxProps } from './Box';
import { Tooltip } from './Tooltip';

export const ImageButton = (props) => {
  const {
    className,
    color,
    disabled,
    disabledContent,
    image,
    imageSize,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    content,
    children,
    onClick,
    ...rest
  } = props;
  rest.onClick = (e) => {
    if (!disabled && onClick) {
      onClick(e);
    }
  };
  let buttonContent = (
    <div
      className={classes([
        'SpriteButton',
        selected && 'SpriteButton--selected',
        disabled && 'SpriteButton--disabled',
        color && typeof color === 'string'
          ? 'SpriteButton--color--' + color
          : 'SpriteButton--color--default',
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={!disabled && '0'}
      {...computeBoxProps(rest)}
    >
      <img
        src={`data:image/jpeg;base64,${image}`}
        style={{
          width: imageSize,
          '-ms-interpolation-mode': 'nearest-neighbor',
        }}
      />
      {content && (
        <div
          className={classes([
            'SpriteButton__content',
            ellipsis && 'SpriteButton__content--ellipsis',
            selected && 'SpriteButton__content--selected',
            disabled && 'SpriteButton__content--disabled',
            color && typeof color === 'string'
              ? 'SpriteButton__content--color--' + color
              : 'SpriteButton__content--color--default',
            className,
            computeBoxClassName(rest),
          ])}
        >
          {disabled ? disabledContent : content}
        </div>
      )}
      {children}
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition}>
        {buttonContent}
      </Tooltip>
    );
  }

  return buttonContent;
};

ImageButton.defaultHooks = pureComponentHooks;
