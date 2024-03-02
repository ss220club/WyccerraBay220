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
    asset,
    color,
    title,
    vertical,
    content,
    selected,
    disabled,
    disabledContent,
    image,
    imageAsset,
    imageSize,
    tooltip,
    tooltipPosition,
    ellipsis,
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
        vertical ? 'ImageButton__vertical' : 'ImageButton__horizontal',
        selected && 'ImageButton--selected',
        disabled && 'ImageButton--disabled',
        color && typeof color === 'string'
          ? 'ImageButton--color--' + color
          : 'ImageButton--color--default',
        className,
        computeBoxClassName(rest),
      ])}
      tabIndex={!disabled && '0'}
      {...computeBoxProps(rest)}
    >
      <div className={classes(['ImageButton__image'])}>
        {asset ? (
          <div className={classes([imageAsset, image])} />
        ) : (
          <img
            src={`data:image/jpeg;base64,${image}`}
            style={{
              width: imageSize,
              '-ms-interpolation-mode': 'nearest-neighbor',
            }}
          />
        )}
      </div>
      {content &&
        (vertical ? (
          <div
            className={classes([
              'ImageButton__content__vertical',
              ellipsis && 'ImageButton__content--ellipsis',
              selected && 'ImageButton__content--selected',
              disabled && 'ImageButton__content--disabled',
              color && typeof color === 'string'
                ? 'ImageButton__content--color--' + color
                : 'ImageButton__content--color--default',
              className,
              computeBoxClassName(rest),
            ])}
          >
            {disabled ? disabledContent : content}
            <br />
            {children}
          </div>
        ) : (
          <div className={classes(['ImageButton__content__horizontal'])}>
            {title && (
              <div
                className={classes(['ImageButton__content__horizontal--title'])}
              >
                {title}
                <div
                  className={classes([
                    'ImageButton__content__horizontal--divider',
                  ])}
                />
              </div>
            )}
            <div
              className={classes(['ImageButton__content__horizontal--content'])}
            >
              {content}
              <br />
              {children}
            </div>
          </div>
        ))}
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
