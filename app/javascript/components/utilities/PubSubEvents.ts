export const PUBSUB_RECHECK_ALL_VALIDATIONS_FINISHED = "RECHECK_ALL_VALIDATIONS_FINISHED";
export const PUBSUB_RECHECK_ALL_VALIDATIONS_PROGRESS = "RECHECK_ALL_VALIDATIONS_PROGRESS";

export const PUBSUB_CHECK_PLACEHOLDERS_FINISHED = "CHECK_PLACEHOLDERS_FINISHED";
export const PUBSUB_CHECK_PLACEHOLDERS_PROGRESS = "CHECK_PLACEHOLDERS_PROGRESS";

export type PUBSUB_EVENTS =
    | typeof PUBSUB_RECHECK_ALL_VALIDATIONS_FINISHED
    | typeof PUBSUB_RECHECK_ALL_VALIDATIONS_PROGRESS
    | typeof PUBSUB_CHECK_PLACEHOLDERS_FINISHED
    | typeof PUBSUB_CHECK_PLACEHOLDERS_PROGRESS;