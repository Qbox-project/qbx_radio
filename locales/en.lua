local Translations = {
    not_on_channel = 'You\'re not connected to a channel',
    on_channel = 'You\'re already connected to this channel',
    joined_radio = 'You\'re connected to: ',
    restricted_channel = 'You can not connect to this channel',
    invalid_channel = 'This frequency is not available',
    left_channel = 'You left the channel',
    min_volume = 'The radio is already set to the lowest volume',
    max_volume = 'he radio is already set to maximum volume',
    new_volume = 'New volume: ',
    new_channel = 'New channel: '
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
