#!/bin/bash
#Created by Nima Behkar / v1.3

OPEN_HTML=1 # Default value to open HTML file
FOLDER_PATH="$1"
HTML_FILE="$FOLDER_PATH/___.html"
DEL_FILE=$(ls -t "$FOLDER_PATH"/___del*.txt | head -n 1)

# Filtering image and video files
FILE_LIST=$(find "$FOLDER_PATH" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.heif" -o -iname "*.mp4" -o -iname "*.webm" -o -iname "*.ogg" \))

# Counting total files and listed image and video files and other files
TOTAL_FILE_COUNT=$(ls "$FOLDER_PATH" | wc -l)
IMAGE_FILE_COUNT=$(echo "$FILE_LIST" | grep -E "\.jpg|\.jpeg|\.png|\.bmp|\.gif|\.tiff|\.heif" | wc -l)
VIDEO_FILE_COUNT=$(echo "$FILE_LIST" | grep -E "\.mp4|\.webm|\.ogg" | wc -l)
NON_IMAGE_VIDEO_COUNT=$((TOTAL_FILE_COUNT - IMAGE_FILE_COUNT - VIDEO_FILE_COUNT))

# folder size
FOLDER_SIZE=$(du -sh "$FOLDER_PATH" | cut -f1)

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
        if [ -z "$FILENAME" ]; then
          continue
        fi
        FULL_PATH="$FOLDER_PATH/$FILENAME"
        if [ -f "$FULL_PATH" ]; then
          DEL_LIST+="$FULL_PATH\n"
        else
          echo "File not found: $FULL_PATH"
        fi
      done < "$DEL_FILE"
      
      # Displaying the count of files to be deleted
      DEL_COUNT=$(( $(echo -e "$DEL_LIST" | wc -l) - 1 ))
      osascript -e "tell app \"System Events\" to display dialog \"Number of files to be deleted: $DEL_COUNT\""

      # Sending file list for deletion to the next Automator action
      echo -e "$DEL_LIST"
    else
      # Displaying a message if del.txt does not exist
      osascript -e 'tell app "System Events" to display dialog "___del.txt file does not exist. Copy this file to main folder then retry."'
      OPEN_HTML=0
    fi
  else
    OPEN_HTML=0
  fi
else
  # Creating a HTML file with a list of images
  echo "<html><head><style>" > "$HTML_FILE"
  #styles:
  echo "body{background-color:#000;}.image{border:2px solid #fff;margin:2px;width:calc(33.33% - 5px)}.video-container{margin:2px;width:calc(33.33% - 9px);position:relative;display:inline-block}.video{border:2px solid #fff;width:100%;height:auto}.play-icon{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:2em;color:#fff;pointer-events:none;display:block}.video-container:hover .play-icon{display:none}#speakerIcon{cursor:pointer}.selected{border:2px solid red}#fixedContainer{position:fixed;top:0;width:100%;background-color:#fff;opacity:.3;transition:opacity 0.3s;z-index:100;display:flex;align-items:center;justify-content:left;padding:10px}#fixedContainer:hover{opacity:1}#fixedContainer *{margin-right:10px}#selectedImages{width:400px;height:30px;white-space:pre;overflow:auto;margin-bottom:5px;margin-top:15px}.imagesContainer{width:80%;margin:auto}#shortcutGuide{direction:rtl}.modal{display:none;position:fixed;z-index:1;left:0;top:0;width:100%;height:100%;overflow:auto;background-color:rgba(0,0,0,.9)}.modal-content{margin:auto;display:block;width:auto;max-width:100%;padding-top:3%}#modalCaption{color:#fff;text-align:center;padding:10px}" >> "$HTML_FILE"
  echo "</style><script>" >> "$HTML_FILE"
  #js scripts:
  echo "var selectedImages=[],keysPressed={};function changeBackgroundColor(e){document.body.style.backgroundColor=e}function updateContainerWidth(){var e=document.getElementById(\"containerWidthRange\").value;document.getElementsByClassName(\"imagesContainer\")[0].style.width=e+\"%\"}function updateImages(){for(var e=document.getElementById(\"imageRange\").value,t=100/e-.5,n=document.querySelectorAll(\".image, .video-container\"),d=0;d<n.length;d++)n[d].style.width=\"calc(\"+t+\"% - 4px)\";document.getElementById(\"rangeValue\").textContent=e}function updateSelectedImagesDisplay(){document.getElementById(\"selectedImages\").value=selectedImages.join(\"\n\")}function toggleSelection(e){var t=e.getAttribute(\"src\"),n=selectedImages.indexOf(t);n>-1?(selectedImages.splice(n,1),e.classList.remove(\"selected\")):(selectedImages.push(t),e.classList.add(\"selected\")),updateSelectedImagesDisplay()}function selectAllImages(){var e=document.querySelectorAll(\".image, .video\");selectedImages=[];for(var t=0;t<e.length;t++){var n=e[t].getAttribute(\"src\");selectedImages.push(n),e[t].classList.add(\"selected\")}updateSelectedImagesDisplay()}function reverseSelections(){var e=document.querySelectorAll(\".image, .video\");selectedImages=[];for(var t=0;t<e.length;t++){var n=e[t].getAttribute(\"src\");e[t].classList.contains(\"selected\")?e[t].classList.remove(\"selected\"):(selectedImages.push(n),e[t].classList.add(\"selected\"))}updateSelectedImagesDisplay()}function downloadSelectedImages(){var e=document.getElementById(\"selectedImages\").value,t=new Blob([e],{type:\"text/plain\"}),n=document.createElement(\"a\");n.download=\"___del.txt\",n.href=window.URL.createObjectURL(t),n.style.display=\"none\",document.body.appendChild(n),n.click(),document.body.removeChild(n)}window.onload=function(){var e=document.createElement(\"div\");e.id=\"fixedContainer\";var t=document.createElement(\"input\");t.type=\"range\",t.id=\"imageRange\",t.min=\"1\",t.max=\"10\",t.value=\"4\",t.oninput=function(){updateImages(),this.blur()};var n=document.createElement(\"span\");n.id=\"rangeValue\";var d=document.createElement(\"input\");d.type=\"range\",d.id=\"containerWidthRange\",d.min=\"30\",d.max=\"100\",d.value=\"80\",d.oninput=updateContainerWidth;var s=document.createElement(\"div\");s.style.width=\"20px\",s.style.height=\"20px\",s.style.backgroundColor=\"black\",s.onclick=function(){changeBackgroundColor(\"black\")};var a=document.createElement(\"div\");a.style.width=\"20px\",a.style.height=\"20px\",a.style.backgroundColor=\"white\",a.style.border=\"1px solid black\",a.onclick=function(){changeBackgroundColor(\"white\")};var l=document.createElement(\"button\");l.textContent=\"Revert Selection\",l.onclick=reverseSelections;var o=document.createElement(\"button\");o.textContent=\"Select All\",o.onclick=selectAllImages;var c=document.createElement(\"button\");c.textContent=\"Download Selected Files\",c.style.backgroundColor=\"red\",c.onclick=downloadSelectedImages;var i=document.createElement(\"textarea\");i.id=\"selectedImages\",i.readOnly=!0,e.appendChild(t),e.appendChild(n),document.body.insertBefore(e,document.body.firstChild),document.body.insertBefore(i,e.nextSibling),e.appendChild(d),e.appendChild(s),e.appendChild(a),e.appendChild(l),e.appendChild(o),e.appendChild(c);for(var r=document.querySelectorAll(\".image, .video\"),m=0;m<r.length;m++)r[m].addEventListener(\"click\",(function(e){e.shiftKey||toggleSelection(this)}));var u=document.createElement(\"div\");u.id=\"shortcutGuide\",u.textContent=\"Shortcuts: Press SHIFT+Click (Open Modal), R+V (Revert Selection), CMD+A (Select All), D+L (Download Selected)\",document.body.insertBefore(u,document.body.firstChild);var g=document.getElementById(\"fixedContainer\"),y=document.createElement(\"div\");y.id=\"speakerIcon\",y.textContent=\"🔊\",g.appendChild(y);var p=!1;y.addEventListener(\"click\",(function(){p=!p,y.textContent=p?\"🔇\":\"🔊\";for(var e=document.getElementsByTagName(\"video\"),t=0;t<e.length;t++)e[t].muted=p}));var v=document.getElementById(\"imageModal\"),h=document.getElementById(\"modalImage\"),f=document.getElementById(\"modalVideo\"),k=document.getElementById(\"modalCaption\"),C=document.getElementsByClassName(\"image\");for(m=0;m<C.length;m++)C[m].addEventListener(\"click\",(function(e){e.shiftKey&&(v.style.display=\"block\",h.src=this.src,h.style.display=\"block\",f.style.display=\"none\",k.textContent=this.src.split(\"/\").pop())}));for(var E=document.getElementsByClassName(\"video\"),I=0;I<E.length;I++)E[I].addEventListener(\"mouseenter\",(function(){this.play()})),E[I].addEventListener(\"mouseleave\",(function(){this.pause()})),E[I].addEventListener(\"click\",(function(e){e.shiftKey&&(v.style.display=\"block\",f.src=this.src,f.style.display=\"block\",h.style.display=\"none\",k.textContent=this.src.split(\"/\").pop())}));function b(e){parseInt(document.getElementById(\"imageRange\").value,10);var t=document.getElementsByClassName(\"image\")[0],n=t.offsetHeight+parseInt(window.getComputedStyle(t).marginBottom,10),d=window.pageYOffset||document.documentElement.scrollTop,s=\"down\"===e?d+n+15:d-n-15;window.scrollTo(0,s)}window.addEventListener(\"click\",(function(e){e.target!=v&&\"Escape\"!==e.key||(v.style.display=\"none\",f.paused||f.pause())})),window.addEventListener(\"keydown\",(function(e){\"Escape\"===e.key&&(v.style.display=\"none\",f.paused||f.pause())})),document.addEventListener(\"mousemove\",(function(e){e.shiftKey?(e.target.classList.contains(\"image\")||e.target.classList.contains(\"video\"))&&(e.target.style.cursor=\"pointer\"):(e.target.classList.contains(\"image\")||e.target.classList.contains(\"video\"))&&(e.target.style.cursor=\"default\")})),document.addEventListener(\"keydown\",(function(e){keysPressed[e.key]=!0,keysPressed.Control||keysPressed.Meta?keysPressed.a&&(selectAllImages(),e.preventDefault()):keysPressed.r&&keysPressed.v?(reverseSelections(),e.preventDefault()):keysPressed.d&&keysPressed.l?2===Object.keys(keysPressed).length&&keysPressed.d&&keysPressed.l&&(downloadSelectedImages(),e.preventDefault()):\"PageDown\"===e.key?(b(\"down\"),e.preventDefault()):\"PageUp\"===e.key&&(b(\"up\"),e.preventDefault())})),document.addEventListener(\"keyup\",(function(e){delete keysPressed[e.key]})),updateImages(),setTimeout((function(){for(var e=document.getElementsByClassName(\"image\"),t=0;t<e.length;t++)e[t].complete&&0!==e[t].naturalWidth||(e[t].style.height=\"fit-content\",e[t].style.position=\"relative\",e[t].style.bottom=\"4px\")}),2e3)};" >> "$HTML_FILE"
  echo "</script></head><body><div class=\"imagesContainer\">" >> "$HTML_FILE"

  # Sorting and addressing video files
  SORTED_VIDEO_LIST=$(find "$FOLDER_PATH" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.webm" -o -iname "*.ogg" \) | sort)
  if [ -n "$SORTED_VIDEO_LIST" ]; then
    echo "$SORTED_VIDEO_LIST" | while IFS= read -r VIDEO; do
      VIDEO_FILENAME=$(basename "$VIDEO")
      echo "<div class=\"video-container\"><video class=\"video\" src=\"$VIDEO_FILENAME\"></video><div class=\"play-icon\">&#9658;</div></div>" >> "$HTML_FILE"
    done
  fi

  # Sorting and addressing image files
  SORTED_IMAGE_LIST=$(find "$FOLDER_PATH" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.heif" \) | sort)
  if [ -n "$SORTED_IMAGE_LIST" ]; then
    echo "$SORTED_IMAGE_LIST" | while IFS= read -r IMAGE; do
      FILENAME=$(basename "$IMAGE")
      echo "<img class=\"image\" src=\"$FILENAME\">" >> "$HTML_FILE"
    done
  fi

  echo "</div><div id=\"imageModal\" class=\"modal\"><img class=\"modal-content\" id=\"modalImage\"><video class=\"modal-content\" id=\"modalVideo\" controls style=\"display: none;\"></video><div id=\"modalCaption\"></div></div></body></html>" >> "$HTML_FILE"
  # Displaying a message after creating HTML file with images list
  osascript -e "tell app \"System Events\" to display dialog \"Total files: $TOTAL_FILE_COUNT\nListed image files: $IMAGE_FILE_COUNT\nListed video files: $VIDEO_FILE_COUNT\nOther files: $NON_IMAGE_VIDEO_COUNT\n------\nFolder size: $FOLDER_SIZE\n------\nHTML file created with images list.\""
fi

# Opening the HTML file AND Del all selected filename txt files
if [ "$OPEN_HTML" -eq 1 ]; then
  rm "$FOLDER_PATH"/___del*.txt
  open "$HTML_FILE"
fi
