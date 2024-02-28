#!/bin/bash
#Created by Nima Behkar / v1.4.1

OPEN_HTML=1 # Default value to open HTML file
FOLDER_PATH="$1"
HTML_FILE="$FOLDER_PATH/___.html"
DEL_FILE=$(ls -t "$FOLDER_PATH"/___del*.txt | head -n 1)

# Filtering image and video files
FILE_LIST=$(find "$FOLDER_PATH" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" -o -iname "*.tiff" -o -iname "*.heif" -o -iname "*.mp4" -o -iname "*.webm" -o -iname "*.ogg" \))

# Counting total files and listed image and video files and other files
TOTAL_FILE_COUNT=$(ls "$FOLDER_PATH" | wc -l)
IMAGE_FILE_COUNT=$(echo "$FILE_LIST" | grep -iE "\.jpg|\.jpeg|\.png|\.bmp|\.gif|\.tiff|\.heif" | wc -l)
VIDEO_FILE_COUNT=$(echo "$FILE_LIST" | grep -iE "\.mp4|\.webm|\.ogg" | wc -l)
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
  echo "body{background-color:#000}.image{border:2px solid #fff;margin:2px;width:calc(33.33% - 5px)}.video-container{margin:2px;width:calc(33.33% - 9px);position:relative;display:inline-block}.video{border:2px solid #fff;width:100%;height:auto}.play-icon{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:2em;color:#fff;pointer-events:none;display:block}.video-container:hover .play-icon{display:none}#speakerIcon{cursor:pointer}.selected{border:2px solid red}#fixedContainer{position:fixed;top:0;width:100%;background-color:#fff;opacity:.3;transition:opacity 0.3s;z-index:100;display:flex;align-items:center;justify-content:left;padding:10px}#fixedContainer:hover{opacity:1}#fixedContainer *{margin-right:10px}#countDisplay{margin:auto;margin-right:1em;padding-right:1em}#selectedImages{width:400px;height:30px;white-space:pre;overflow:auto;margin-bottom:5px;margin-top:15px}.imagesContainer{width:80%;margin:auto}#shortcutGuide{direction:rtl}.modal{display:none;position:fixed;z-index:1;left:0;top:0;width:100%;height:100%;overflow:auto;background-color:rgba(0,0,0,.9)}.modal-content{margin:auto;display:block;width:auto;max-width:100%;max-height:92%;padding-top:3%}#modalCaption{color:#fff;text-align:center;padding:10px}" >> "$HTML_FILE"
  echo "</style><script>" >> "$HTML_FILE"
  #js scripts:
  echo "var selectedImages=[],keysPressed={};function changeBackgroundColor(e){document.body.style.backgroundColor=e}function updateContainerWidth(){var e=document.getElementById(\"containerWidthRange\").value;document.getElementsByClassName(\"imagesContainer\")[0].style.width=e+\"%\"}function updateImages(){for(var e=(window.scrollY||window.pageYOffset)/document.documentElement.scrollHeight,t=document.getElementById(\"imageRange\").value,n=100/t-.5,s=document.querySelectorAll(\".image, .video-container\"),d=0;d<s.length;d++)s[d].style.width=\"calc(\"+n+\"% - 4px)\";document.getElementById(\"rangeValue\").textContent=t,setTimeout((function(){var t=document.documentElement.scrollHeight,n=e*t;window.scrollTo(0,n)}),100)}function updateSelectedImagesDisplay(){document.getElementById(\"selectedImages\").value=selectedImages.join(\"\n\"),document.getElementById(\"selectedCount\").textContent=selectedImages.length}function toggleSelection(e){var t=e.getAttribute(\"src\"),n=selectedImages.indexOf(t);n>-1?(selectedImages.splice(n,1),e.classList.remove(\"selected\")):(selectedImages.push(t),e.classList.add(\"selected\")),updateSelectedImagesDisplay()}function selectAllImages(){var e=document.querySelectorAll(\".image, .video\");selectedImages=[];for(var t=0;t<e.length;t++){var n=e[t].getAttribute(\"src\");selectedImages.push(n),e[t].classList.add(\"selected\")}updateSelectedImagesDisplay()}function reverseSelections(){var e=document.querySelectorAll(\".image, .video\");selectedImages=[];for(var t=0;t<e.length;t++){var n=e[t].getAttribute(\"src\");e[t].classList.contains(\"selected\")?e[t].classList.remove(\"selected\"):(selectedImages.push(n),e[t].classList.add(\"selected\"))}updateSelectedImagesDisplay()}function downloadSelectedImages(){var e=document.getElementById(\"selectedImages\").value,t=new Blob([e],{type:\"text/plain\"}),n=document.createElement(\"a\");n.download=\"___del.txt\",n.href=window.URL.createObjectURL(t),n.style.display=\"none\",document.body.appendChild(n),n.click(),document.body.removeChild(n)}window.onload=function(){var e=document.createElement(\"div\");e.id=\"fixedContainer\";var t=document.createElement(\"input\");t.type=\"range\",t.id=\"imageRange\",t.min=\"1\",t.max=\"10\",t.value=\"4\",t.oninput=function(){updateImages(),this.blur()};var n=document.createElement(\"span\");n.id=\"rangeValue\";var s=document.createElement(\"input\");s.type=\"range\",s.id=\"containerWidthRange\",s.min=\"30\",s.max=\"100\",s.value=\"80\",s.oninput=updateContainerWidth;var d=document.createElement(\"div\");d.style.width=\"20px\",d.style.height=\"20px\",d.style.backgroundColor=\"black\",d.onclick=function(){changeBackgroundColor(\"black\")};var o=document.createElement(\"div\");o.style.width=\"20px\",o.style.height=\"20px\",o.style.backgroundColor=\"white\",o.style.border=\"1px solid black\",o.onclick=function(){changeBackgroundColor(\"white\")};var l=document.createElement(\"button\");l.textContent=\"Revert Selection\",l.onclick=reverseSelections;var a=document.createElement(\"button\");a.textContent=\"Select All\",a.onclick=selectAllImages;var c=document.createElement(\"button\");c.textContent=\"Download Selected Files\",c.style.backgroundColor=\"red\",c.onclick=downloadSelectedImages;var i=document.createElement(\"textarea\");i.id=\"selectedImages\",i.readOnly=!0,e.appendChild(t),e.appendChild(n),document.body.insertBefore(e,document.body.firstChild),document.body.insertBefore(i,e.nextSibling),e.appendChild(s),e.appendChild(d),e.appendChild(o),e.appendChild(l),e.appendChild(a),e.appendChild(c);var r=document.createElement(\"div\");r.id=\"speakerIcon\",r.textContent=\"🔊\",e.appendChild(r);var m=!1;r.addEventListener(\"click\",(function(){m=!m,r.textContent=m?\"🔇\":\"🔊\";for(var e=document.getElementsByTagName(\"video\"),t=0;t<e.length;t++)e[t].muted=m}));var u=document.createElement(\"div\");u.id=\"countDisplay\",u.textContent=\"Total: \"+document.querySelectorAll(\".image, .video\").length+\" / Selected: \";var g=document.createElement(\"span\");g.id=\"selectedCount\",g.textContent=\"0\",u.appendChild(g),e.appendChild(u);for(var y=document.querySelectorAll(\".image, .video\"),p=0;p<y.length;p++)y[p].addEventListener(\"click\",(function(e){e.shiftKey||toggleSelection(this)}));var v=document.createElement(\"div\");v.id=\"shortcutGuide\",v.textContent=\"Shortcuts: Press SHIFT+Click (Open Modal), R+V (Revert Selection), CMD+A (Select All), D+L (Download Selected)\",document.body.insertBefore(v,document.body.firstChild);var h=document.getElementById(\"imageModal\"),f=document.getElementById(\"modalImage\"),k=document.getElementById(\"modalVideo\"),C=document.getElementById(\"modalCaption\"),E=document.getElementsByClassName(\"image\");for(p=0;p<E.length;p++)E[p].addEventListener(\"click\",(function(e){if(e.shiftKey){var t=decodeURIComponent(new URL(this.src).pathname.split(\"/\").pop());h.style.display=\"block\",document.body.style.overflow=\"hidden\",f.src=t,f.style.display=\"block\",k.style.display=\"none\",C.textContent=t,selectedImages.includes(t)?f.classList.add(\"selected\"):f.classList.remove(\"selected\")}}));f.addEventListener(\"click\",(function(){var e=decodeURIComponent(new URL(this.src).pathname.split(\"/\").pop());toggleSelection(document.querySelector('img[src=\"'+e+'\"]')),selectedImages.includes(e)?this.classList.add(\"selected\"):this.classList.remove(\"selected\")}));for(var I=document.getElementsByClassName(\"video\"),w=0;w<I.length;w++)I[w].addEventListener(\"mouseenter\",(function(){this.play()})),I[w].addEventListener(\"mouseleave\",(function(){this.pause()})),I[w].addEventListener(\"click\",(function(e){if(e.shiftKey){var t=decodeURIComponent(new URL(this.src).pathname.split(\"/\").pop());h.style.display=\"block\",document.body.style.overflow=\"hidden\",k.src=t,k.style.display=\"block\",f.style.display=\"none\",C.textContent=t,selectedImages.includes(t)?k.classList.add(\"selected\"):k.classList.remove(\"selected\")}}));function L(e){parseInt(document.getElementById(\"imageRange\").value,10);var t=document.getElementsByClassName(\"image\")[0],n=t.offsetHeight+parseInt(window.getComputedStyle(t).marginBottom,10),s=window.pageYOffset||document.documentElement.scrollTop,d=\"down\"===e?s+n+15:s-n-15;window.scrollTo(0,d)}k.addEventListener(\"click\",(function(){var e=decodeURIComponent(new URL(this.src).pathname.split(\"/\").pop());toggleSelection(document.querySelector('video[src=\"'+e+'\"]')),selectedImages.includes(e)?this.classList.add(\"selected\"):this.classList.remove(\"selected\")})),window.addEventListener(\"click\",(function(e){e.target!=h&&\"Escape\"!==e.key||(h.style.display=\"none\",document.body.style.overflow=\"\",k.paused||k.pause())})),window.addEventListener(\"keydown\",(function(e){\"Escape\"===e.key&&(h.style.display=\"none\",document.body.style.overflow=\"\",k.paused||k.pause())})),document.addEventListener(\"mousemove\",(function(e){e.shiftKey?(e.target.classList.contains(\"image\")||e.target.classList.contains(\"video\"))&&(e.target.style.cursor=\"pointer\"):(e.target.classList.contains(\"image\")||e.target.classList.contains(\"video\"))&&(e.target.style.cursor=\"default\")})),document.addEventListener(\"mousemove\",(function(e){if(e.ctrlKey){var t=e.target;(t.classList.contains(\"image\")||t.classList.contains(\"video\"))&&t!==lastHoveredMedia&&(toggleSelection(t),lastHoveredMedia=t)}})),(y=document.querySelectorAll(\".image, .video\")).forEach((function(e){e.addEventListener(\"mouseleave\",(function(){lastHoveredMedia=null}))})),document.addEventListener(\"keydown\",(function(e){keysPressed[e.key]=!0,keysPressed.Control||keysPressed.Meta?keysPressed.a&&(selectAllImages(),e.preventDefault()):keysPressed.r&&keysPressed.v?(reverseSelections(),e.preventDefault()):keysPressed.d&&keysPressed.l?2===Object.keys(keysPressed).length&&keysPressed.d&&keysPressed.l&&(downloadSelectedImages(),e.preventDefault()):\"PageDown\"===e.key||\"z\"===e.key||\"Z\"===e.key?(L(\"down\"),e.preventDefault()):\"PageUp\"!==e.key&&\"a\"!==e.key&&\"A\"!==e.key||(L(\"up\"),e.preventDefault())})),document.addEventListener(\"keyup\",(function(e){delete keysPressed[e.key]})),document.addEventListener(\"keydown\",(function(e){if(\"block\"===h.style.display&&(\"ArrowRight\"===e.key||\"ArrowLeft\"===e.key)){var t=\"block\"===f.style.display?f:k;t!==k||k.paused||k.pause();var n=decodeURIComponent(new URL(t.src).pathname.split(\"/\").pop()),s=function(e,t){var n,s=document.querySelectorAll(\".image, .video\");if(\"next\"===t)(n=e+1)>=s.length&&(n=0);else if((n=e-1)<0)return e;return s[n]}(Array.from(document.querySelectorAll(\".image, .video\")).indexOf(document.querySelector('[src$=\"'+n+'\"]')),\"ArrowRight\"===e.key?\"next\":\"previous\");if(!s)return;var d=decodeURIComponent(new URL(s.src).pathname.split(\"/\").pop());s.classList.contains(\"image\")?(f.src=d,f.style.display=\"block\",k.style.display=\"none\"):s.classList.contains(\"video\")&&(k.src=d,k.style.display=\"block\",f.style.display=\"none\"),C.textContent=d,selectedImages.includes(d)?(f.classList.add(\"selected\"),k.classList.add(\"selected\")):(f.classList.remove(\"selected\"),k.classList.remove(\"selected\"))}})),updateImages(),setTimeout((function(){for(var e=document.getElementsByClassName(\"image\"),t=0;t<e.length;t++)e[t].complete&&0!==e[t].naturalWidth||(e[t].style.height=\"fit-content\",e[t].style.position=\"relative\",e[t].style.bottom=\"4px\")}),2e3)};" >> "$HTML_FILE"
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
