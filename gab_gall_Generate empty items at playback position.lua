-- Function to display a dialog box and get user input
function getUserInput()
  local ret, userInputs = reaper.GetUserInputs("Generate Empty Items", 4, "Number of Items,Length (seconds),Spacing (seconds),Name Prefix", "")
  
  if not ret then
    return nil
  end

  local numItems, length, spacing, namePrefix = userInputs:match("([^,]+),([^,]+),([^,]+),([^,]+)")

  return {
    numItems = tonumber(numItems),
    length = tonumber(length),
    spacing = tonumber(spacing),
    namePrefix = namePrefix
  }
end

-- Function to create empty items based on user input
function generateEmptyItems()
  local userInput = getUserInput()

  if not userInput then
    return
  end

  local numItems = userInput.numItems
  local length = userInput.length
  local spacing = userInput.spacing
  local namePrefix = userInput.namePrefix

  local track

  -- Check if the "ITEMS" track exists, create one if not
  local numTracks = reaper.CountTracks(0)
  local itemsTrackIdx = -1

  for i = 0, numTracks - 1 do
    local currentTrack = reaper.GetTrack(0, i)
    local retval, trackName = reaper.GetSetMediaTrackInfo_String(currentTrack, "P_NAME", "", false)

    if trackName == "ITEMS" then
      itemsTrackIdx = i
      track = currentTrack
      break
    end
  end

  if itemsTrackIdx == -1 then
    -- Insert a new track at the top
    reaper.InsertTrackAtIndex(0, false)
    track = reaper.GetTrack(0, 0)
    
    -- Set the track name and color
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "ITEMS", true)
    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    reaper.SetTrackColor(track, reaper.ColorToNative(r, g, b))
  end

  -- Get the current playback position
  local position = reaper.GetCursorPosition()

  -- Create empty items
  for i = 1, numItems do
    local item = reaper.AddMediaItemToTrack(track)
    reaper.SetMediaItemPosition(item, position + (i - 1) * (length + spacing), false)
    reaper.SetMediaItemLength(item, length, false)

    -- Set the name of the item with prefix and number
    local itemName = string.format("%s%02d", namePrefix, i)
    reaper.GetSetMediaItemInfo_String(item, "P_NOTES", itemName, true)
  end
end

-- Run the script
generateEmptyItems()

