#!/bin/bash

FOLDER_PATH="$1"
HTML_FILE="$FOLDER_PATH/___.html"
DEL_FILE="$FOLDER_PATH/del.txt"

# Filtering only image files
FILE_LIST=$(find "$FOLDER_PATH" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.heif" \))

# Counting total files and listed image files
TOTAL_FILE_COUNT=$(ls "$FOLDER_PATH" | wc -l)
IMAGE_FILE_COUNT=$(echo "$FILE_LIST" | wc -l)

# Checking for the existence of the HTML file
if [ -f "$HTML_FILE" ]; then
  # Asking to delete selected files
  RESPONSE=$(osascript -e 'tell app "System Events" to display dialog "Do you want to delete selected files?" buttons {"Yes", "No"} default button 2')
  if [[ $RESPONSE == *"Yes"* ]]; then
    # Checking for the existence of del.txt
    if [ -f "$DEL_FILE" ]; then
      # Preparing the list of files to be deleted
      DEL_LIST=""
      while IFS= read -r FILENAME || [[ -n "$FILENAME" ]]; do
        FULL_PATH="$FOLDER_PATH/$FILENAME"
        DEL_LIST+="$FULL_PATH\n"
      done < "$DEL_FILE"
      
      # Displaying the files to be deleted for debugging
      # osascript -e "tell app \"System Events\" to display dialog \"Files to be deleted:\n$DEL_LIST\""

      # Sending file list for deletion to the next Automator action
      echo -e "$DEL_LIST"
    else
      # Displaying a message if del.txt does not exist
      osascript -e 'tell app "System Events" to display dialog "del.txt file does not exist."'
    fi
  fi
else
  # Creating a simple HTML file with a list of images
  echo "<html><head><style>.image { border: 2px solid white; margin: 2px; width: calc(33.33% - 4px); } .selected { border: 2px solid red; } #sliderContainer { position: fixed; top: 0; width: 100%; background-color: white; opacity: 0.3; transition: opacity 0.3s; z-index: 100; } #sliderContainer:hover { opacity: 1; } #selectedImages { width: 400px; height: 30px; white-space: pre; overflow: auto; margin-bottom: 5px; margin-top: 15px; } .imagesContainer { clear: both; }</style><script>var selectedImages = []; var keysPressed = {}; function updateImages() { var numberOfImages = document.getElementById('imageRange').value; var percentWidth = 100 / numberOfImages - 0.5; var images = document.getElementsByClassName('image'); for (var i = 0; i < images.length; i++) { images[i].style.width = 'calc(' + percentWidth + '% - 4px)'; } document.getElementById('rangeValue').textContent = numberOfImages; } function updateSelectedImagesDisplay() { document.getElementById('selectedImages').value = selectedImages.join('\\n'); } function toggleSelection(image) { var imageName = image.getAttribute('src'); var index = selectedImages.indexOf(imageName); if (index > -1) { selectedImages.splice(index, 1); image.classList.remove('selected'); } else { selectedImages.push(imageName); image.classList.add('selected'); } updateSelectedImagesDisplay(); } function selectAllImages() { var images = document.getElementsByClassName('image'); selectedImages = []; for (var i = 0; i < images.length; i++) { var imageName = images[i].getAttribute('src'); selectedImages.push(imageName); images[i].classList.add('selected'); } updateSelectedImagesDisplay(); } function reverseSelections() { var images = document.getElementsByClassName('image'); selectedImages = []; for (var i = 0; i < images.length; i++) { var imageName = images[i].getAttribute('src'); if (images[i].classList.contains('selected')) { images[i].classList.remove('selected'); } else { selectedImages.push(imageName); images[i].classList.add('selected'); } } updateSelectedImagesDisplay(); } function downloadSelectedImages() { var text = document.getElementById('selectedImages').value; var blob = new Blob([text], { type: 'text/plain' }); var a = document.createElement('a'); a.download = 'del.txt'; a.href = window.URL.createObjectURL(blob); a.style.display = 'none'; document.body.appendChild(a); a.click(); document.body.removeChild(a); } window.onload = function() { var sliderContainer = document.createElement('div'); sliderContainer.id = 'sliderContainer'; var slider = document.createElement('input'); slider.type = 'range'; slider.id = 'imageRange'; slider.min = '1'; slider.max = '20'; slider.value = '3'; slider.oninput = function() { updateImages(); this.blur(); }; var sliderValue = document.createElement('span'); sliderValue.id = 'rangeValue'; var selectedImagesDiv = document.createElement('textarea'); selectedImagesDiv.id = 'selectedImages'; selectedImagesDiv.readOnly = true; sliderContainer.appendChild(slider); sliderContainer.appendChild(sliderValue); document.body.insertBefore(sliderContainer, document.body.firstChild); document.body.insertBefore(selectedImagesDiv, sliderContainer.nextSibling); var images = document.getElementsByClassName('image'); for (var i = 0; i < images.length; i++) { images[i].addEventListener('click', function() { toggleSelection(this); }); } function scrollToNextRow(direction) { var imagesPerRow = parseInt(document.getElementById('imageRange').value, 10); var firstImage = document.getElementsByClassName('image')[0]; var rowHeight = firstImage.offsetHeight + parseInt(window.getComputedStyle(firstImage).marginBottom, 10); var currentPosition = window.pageYOffset || document.documentElement.scrollTop; var newRowPosition = direction === 'down' ? currentPosition + rowHeight + 15 : currentPosition - rowHeight - 15; window.scrollTo(0, newRowPosition); } document.addEventListener('keydown', function(e) { keysPressed[e.key] = true; if (keysPressed['Control'] || keysPressed['Meta']) { if (keysPressed['a']) { selectAllImages(); e.preventDefault(); } } else if (keysPressed['r'] && keysPressed['v']) { reverseSelections(); e.preventDefault(); } else if (keysPressed['d'] && keysPressed['l']) { if (Object.keys(keysPressed).length === 2 && keysPressed['d'] && keysPressed['l']) { downloadSelectedImages(); e.preventDefault(); } } else if (e.key === 'PageDown') { scrollToNextRow('down'); e.preventDefault(); } else if (e.key === 'PageUp') { scrollToNextRow('up'); e.preventDefault(); } }); document.addEventListener('keyup', function(e) { delete keysPressed[e.key]; }); updateImages(); };</script></head><body><div class=\"imagesContainer\">" > "$HTML_FILE"

  # Filtering and addressing image files
  find "$FOLDER_PATH" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.heif" \) | while IFS= read -r IMAGE; do
    # Extracting only the file name from the full path
    FILENAME=$(basename "$IMAGE")
    echo "<img class=\"image\" src=\"$FILENAME\">" >> "$HTML_FILE"
  done

  echo "</div></body></html>" >> "$HTML_FILE"
  # Displaying a message after creating HTML file with images list
  osascript -e "tell app \"System Events\" to display dialog \"Total files: $TOTAL_FILE_COUNT\nListed image files: $IMAGE_FILE_COUNT\n------\nHTML file created with images list.\""
fi

# Opening the HTML file
open "$HTML_FILE"
