---@meta

---Provides an interface for interacting with user profiles, such as retrieving XUIDs, GamerTags, achievements, and more.
---@class Profile
Profile = {}

---Gets the XUID of the specified player.
---@param playerIndex integer The index of the player (1 to 4).
---@return string # The XUID as a hexadecimal string.
---@since 0.6b
function Profile.GetXUID(playerIndex) end

---Gets the GamerTag of the specified player.
---@param playerIndex integer The index of the player (1 to 4).
---@return string # The GamerTag of the player.
---@since 0.6b
function Profile.GetGamerTag(playerIndex) end

---Gets the gamer score of the specified player.
---@param playerIndex integer The index of the player (1 to 4).
---@return integer # The gamer score of the player.
---@since 0.6b
function Profile.GetGamerScore(playerIndex) end

---@alias AchievementInfo { EarnedCount: unsigned, MaxCount: unsigned, EarnedScore: unsigned, MaxScore: unsigned }

---Gets the achievement information for the specified title and player.
---@param playerIndex integer The index of the player (1 to 4).
---@param titleId integer The title ID of the game.
---@return AchievementInfo|0|-1 # Returns a table containing the achievement information, 0 if no achievements were found, or -1 if the player is not signed in.
---@since 0.6b
function Profile.GetTitleAchievement(playerIndex, titleId) end

---@alias ProfileInfo { DeviceID: unsigned, XUID: string, GamerTag: string }

---Enumerates the profiles on the system.
---@return ProfileInfo[] # A table with an array of entries containing the XUID, DeviceID, and GamerTag, or an empty table if no profiles were found.
---@since 0.7b
function Profile.EnumerateProfiles() end

---Gets the profile picture for the specified XUID.
---@param xuid string The XUID of the user.
---@param path string The path where the profile picture will be saved.
---@return boolean # True if the profile picture was successfully retrieved, false otherwise.
---@since 0.7b
function Profile.GetProfilePicture(xuid, path) end

---Logs in a player using the specified XUID.
---@param playerIndex integer The index of the player (1 to 4).
---@param xuid string The XUID of the user in hexadecimal string format.
---@return boolean # True if the login was successful, false otherwise.
---@since 0.7b
function Profile.Login(playerIndex, xuid) end

---Logs out the specified player.
---@param playerIndex integer The index of the player (1 to 4).
---@return boolean # True if the logout was successful, false otherwise.
---@since 0.7b
function Profile.Logout(playerIndex) end

return Profile
