DEFAULT_SITE_SETTINGS = {
  attendance_loss: -0.1,
  attendance_gain: 1.0,
  delinquent_loss: -1.0,
  tardiness_cutoff_time: 60,
}
DATETIME_FORMAT = '%m/%d/%Y %I:%M %p'
DEFAULT_RAID_END_TIME = {
  hour: 22,
  min: 00,
}
DEFAULT_RAID_START_TIME = {
  hour: 18,
  min: 00,
}
PARTICIPATION_EVENTS = {
  invited: 'Invited to Raid',
  logged_in: {
    in_raid: 'Logged In (In Raid)',
    not_in_raid: 'Logged In (Not in Raid)'
  },
  logged_out: {
    in_raid: 'Logged Out (In Raid)',
    not_in_raid: 'Logged Out (Not in Raid)'
  },
  offline: {
    in_raid: 'Offline (In Raid)',
    not_in_raid: 'Offline (Not in Raid)'
  },
  online: {
    in_raid: 'Online (In Raid)',
    not_in_raid: 'Online (Not in Raid)'
  },
  removed: 'Removed from Raid'
}
PARTICIPATION_STATUS_HASH = [['Invited', 'invited'], ['Online', 'online'], ['Absent (Excused)', 'absent_excused'], ['Absent (Unexcused)', 'absent_unexecused']]
PARTICIPATION_STATUS = {
  excused: 'absent_excused',
  invited: 'invited',
  online: 'online',
  unexcused: 'absent_unexcused'
}
WOW_FACTION_HASH = [["horde", "Horde"], ["alliance", "Alliance"], ["neutral", "Neutral"]]
WOW_REGION_HASH = [["US", "us"], ["EU", "eu"], ["KR", "kr"], ["TW", "tw"]]
WOW_REGION_LIST = ["us", "eu", "kr", "tw", "US", "EU", "KR", "TW"]
WOW_ZONE_TYPE_HASH = [
  ['Arena', 'arena'],
  ['Dungeon', 'dungeon'],
  ['Raid', 'raid'],
  ['Scenario', 'scenario'],
  ['Outdoor', 'outdoor']
]
WOW_ZONE_TYPE_LIST = [
  'arena',
  'dungeon',
  'raid',
  'scenario',
  'outdoor'
]
WOW_ZONE_DEFAULTS = [
  {
    level: 90,
    name: "Terrace of Endless Spring",
    zone_type: "raid",
  },
  {
    level: 90,
    name: "Heart of Fear",
    zone_type: "raid",
  },
  {
    level: 90,
    name: "Mogu'shan Vaults",
    zone_type: "raid",
  },
  {
    level: 90,
    name: "Siege of Orgimmar",
    zone_type: "raid",
  },
  {
    level: 90,
    name: "Throne of Thunder",
    zone_type: "raid",
  },
  {
    level: 85,
    name: "The Bastion of Twilight",
    zone_type: "raid",
  },
  {
    level: 85,
    name: "Baradin Hold",
    zone_type: "raid",
  },
  {
    level: 85,
    name: "Dragon Soul",
    zone_type: "raid",
  },
  {
    level: 85,
    name: "Firelands",
    zone_type: "raid",
  },
  {
    level: 85,
    name: "Throne of the Four Winds",
    zone_type: "raid",
  },
  {
    level: 85,
    name: "Blackwing Descent",
    zone_type: "raid",
  },
]