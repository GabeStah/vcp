module CharactersHelper
  def full_character_path(character)
    character_path(name: character.name, region: character.region, realm: character.realm)
  end
end
