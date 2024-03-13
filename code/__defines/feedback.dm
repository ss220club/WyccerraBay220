#define FEEDBACK_YOU_LACK_DEXTERITY USE_FEEDBACK_FAILURE("You don't have the dexterity to do this!")
#define FEEDBACK_ACCESS_DENIED(USER, SRC) FEEDBACK_FAILURE(USER, SPAN_WARNING("\The [SRC] flashes, 'Access Denied!'"))

/// Generic feedback failure message handler.
#define FEEDBACK_FAILURE(USER, MSG) to_chat(USER, SPAN_WARNING(MSG))
/// User can't unequip/drop item.
#define FEEDBACK_UNEQUIP_FAILURE(USER, ITEM) FEEDBACK_FAILURE(USER, "You can't drop \the [ITEM].")

/// Feedback messages intended for use in `use_*` overrides. These assume the presence of the `user` variable.
#define USE_FEEDBACK_FAILURE(MSG) FEEDBACK_FAILURE(user, MSG)
/// ID card lacks access
#define USE_FEEDBACK_ID_CARD_DENIED(REFUSER, ID_CARD) USE_FEEDBACK_FAILURE("\The [REFUSER] refuses [ID_CARD].")
/// Item stack did not have enough items. `STACK` is assumed to be of type `/obj/item/stack`.
#define USE_FEEDBACK_STACK_NOT_ENOUGH(STACK, NEEDED_AMT, ACTION) USE_FEEDBACK_FAILURE("You need at least [STACK.get_exact_name(NEEDED_AMT)] [ACTION]")

/// Feedback messages intended for use in `use_grab()` overrides. These assume the presence of the `grab` variable.
#define USE_FEEDBACK_GRAB_FAILURE(MSG) FEEDBACK_FAILURE(grab.assailant, MSG)
/// Assailant must upgrade their grab to perform action.
#define USE_FEEDBACK_GRAB_MUST_UPGRADE(ACTION) USE_FEEDBACK_GRAB_FAILURE("You need a better grip on \the [grab.affecting][ACTION].")


/// Feedback message when user needs to unanchor the target
#define USE_FEEDBACK_NEED_UNANCHOR balloon_alert(user, "нужно открутить от пола!")
/// Feedback message when user needs to unanchor the target
#define USE_FEEDBACK_NEED_ANCHOR balloon_alert(user, "нужно прикрутить к полу!")
/// Feedback message when user starts deconstructing the target
#define USE_FEEDBACK_DECONSTRUCT_START balloon_alert(user, "разбор")
/// Feedback message when user starts welding/unwelding the target
#define USE_FEEDBACK_WELD_UNWELD(welded) balloon_alert(user, "[welded ? "отваривание" : "заваривание"]")
/// Feedback message when user starts unwelding target from the floor
#define USE_FEEDBACK_UNWELD_FROM_FLOOR balloon_alert(user, "отваривание от пола")

/// Feedback message when user starts repairing the target
#define USE_FEEDBACK_REPAIR_START balloon_alert(user, "ремонт")
/// Feedback message when user finishes the repairs
#define USE_FEEDBACK_REPAIR_FINISH user.visible_message(SPAN_NOTICE("[user] finishes repairing the damage to [src]"), SPAN_NOTICE("You finish repairing the damage to [src]."))
/// Feedback message when the target doesn't need repairs
#define USE_FEEDBACK_NOTHING_TO_REPAIR balloon_alert(user, "нет повреждений!")
