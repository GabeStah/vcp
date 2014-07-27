PARTICIPATION_POSSIBILITIES = {
  nil_nil: {
    false_false: PARTICIPATION_EVENTS[:offline][:not_in_raid],
    false_true: [
      PARTICIPATION_EVENTS[:invited],
      PARTICIPATION_EVENTS[:logged_out][:in_raid],
    ],
    true_false: PARTICIPATION_EVENTS[:online][:not_in_raid],
    true_true: [
      PARTICIPATION_EVENTS[:invited],
      PARTICIPATION_EVENTS[:logged_in][:in_raid],
    ],
  },
  false_false: {
    false_false: nil,
    false_true: [
      PARTICIPATION_EVENTS[:invited],
      PARTICIPATION_EVENTS[:logged_out][:in_raid],
    ],
    true_false: PARTICIPATION_EVENTS[:logged_in][:not_in_raid],
    true_true: [
      PARTICIPATION_EVENTS[:invited],
      PARTICIPATION_EVENTS[:logged_in][:in_raid],
    ],
  },
  false_true: {
    false_false: PARTICIPATION_EVENTS[:removed],
    false_true: nil,
    true_false: [
      PARTICIPATION_EVENTS[:removed],
      PARTICIPATION_EVENTS[:logged_in][:not_in_raid],
    ],
    true_true: PARTICIPATION_EVENTS[:logged_in][:in_raid],
  },
  true_false: {
    false_false: PARTICIPATION_EVENTS[:logged_out][:not_in_raid],
    false_true: [
      PARTICIPATION_EVENTS[:invited],
      PARTICIPATION_EVENTS[:logged_out][:in_raid],
    ],
    true_false: nil,
    true_true: PARTICIPATION_EVENTS[:invited],
  },
  true_true: {
    false_false: [
      PARTICIPATION_EVENTS[:logged_out][:not_in_raid],
      PARTICIPATION_EVENTS[:removed],
    ],
    false_true: PARTICIPATION_EVENTS[:logged_out][:in_raid],
    true_false: PARTICIPATION_EVENTS[:removed],
    true_true: nil,
  },
}