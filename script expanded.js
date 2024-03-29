var selectedImages = [];
	var keysPressed = {};

	// Change the background color of the body
	function changeBackgroundColor(color) {
	    document.body.style.backgroundColor = color;
	}

	// Update the width of the container that holds images and videos
	function updateContainerWidth() {
	    var containerWidth = document.getElementById('containerWidthRange').value;
	    document.getElementsByClassName('imagesContainer')[0].style.width = containerWidth + '%';
	}

	// Update the display of images and videos based on the selected range and scroll to correct position of page
	function updateImages() {
		var scrollPositionY = window.scrollY || window.pageYOffset;
	    var totalHeightBefore = document.documentElement.scrollHeight;
	    var relativePosition = scrollPositionY / totalHeightBefore;

		var numberOfImages = document.getElementById('imageRange').value;
		var percentWidth = 100 / numberOfImages - 0.5;
		var images = document.querySelectorAll('.image, .video-container');
		for(var i = 0; i < images.length; i++) {
			images[i].style.width = 'calc(' + percentWidth + '% - 4px)';
		}
		document.getElementById('rangeValue').textContent = numberOfImages;

		setTimeout(function() {
	        var totalHeightAfter = document.documentElement.scrollHeight;
	        var newScrollPositionY = relativePosition * totalHeightAfter;
	        window.scrollTo(0, newScrollPositionY);
	    }, 100);
	}

	// Update the display of selected images and videos
	function updateSelectedImagesDisplay() {
		document.getElementById('selectedImages').value = selectedImages.join('\n');
		document.getElementById('selectedCount').textContent = selectedImages.length;
	}

	// Toggle selection of an image or video
	function toggleSelection(media) {
		var imageName = media.getAttribute('src');
		var index = selectedImages.indexOf(imageName);
		if(index > -1) {
			selectedImages.splice(index, 1);
			media.classList.remove('selected');
		} else {
			selectedImages.push(imageName);
			media.classList.add('selected');
		}
		updateSelectedImagesDisplay();
	}

	// Select all images and videos
	function selectAllImages() {
		var images = document.querySelectorAll('.image, .video');
		selectedImages = [];
		for(var i = 0; i < images.length; i++) {
			var imageName = images[i].getAttribute('src');
			selectedImages.push(imageName);
			images[i].classList.add('selected');
		}
		updateSelectedImagesDisplay();
	}

	// Reverse the selection of images and videos
	function reverseSelections() {
		var images = document.querySelectorAll('.image, .video');
		selectedImages = [];
		for(var i = 0; i < images.length; i++) {
			var imageName = images[i].getAttribute('src');
			if(images[i].classList.contains('selected')) {
				images[i].classList.remove('selected');
			} else {
				selectedImages.push(imageName);
				images[i].classList.add('selected');
			}
		}
		updateSelectedImagesDisplay();
	}

	// Download selected images and videos as a text file
	function downloadSelectedImages() {
		var text = document.getElementById('selectedImages').value;
		var blob = new Blob([text], {
			type: 'text/plain'
		});
		var a = document.createElement('a');
		a.download = '___del.txt';
		a.href = window.URL.createObjectURL(blob);
		a.style.display = 'none';
		document.body.appendChild(a);
		a.click();
		document.body.removeChild(a);
	}

	// Initialize the page and set up event listeners
	window.onload = function() {
		// Create the main slider container
		var fixedContainer = document.createElement('div');
		fixedContainer.id = 'fixedContainer';

		// Create and configure the image range slider
		var slider = document.createElement('input');
		slider.type = 'range';
		slider.id = 'imageRange';
		slider.min = '1';
		slider.max = '10';
		slider.value = '4';
		slider.oninput = function() {
			updateImages();
			this.blur();
		};

		// Create a span to display the range value
		var sliderValue = document.createElement('span');
		sliderValue.id = 'rangeValue';

		// Create and configure the container width slider
		var containerWidthSlider = document.createElement('input');
	    containerWidthSlider.type = 'range';
	    containerWidthSlider.id = 'containerWidthRange';
	    containerWidthSlider.min = '30';
	    containerWidthSlider.max = '100';
	    containerWidthSlider.value = '80'; // Default value
	    containerWidthSlider.oninput = updateContainerWidth;

	    // Creating color squares for background change
	    var blackSquare = document.createElement('div');
	    blackSquare.style.width = '20px';
	    blackSquare.style.height = '20px';
	    blackSquare.style.backgroundColor = 'black';
	    blackSquare.onclick = function() { changeBackgroundColor('black'); };
	    var whiteSquare = document.createElement('div');
	    whiteSquare.style.width = '20px';
	    whiteSquare.style.height = '20px';
	    whiteSquare.style.backgroundColor = 'white';
	    whiteSquare.style.border = '1px solid black';
	    whiteSquare.onclick = function() { changeBackgroundColor('white'); };

	    // Create buttons for selection actions
	    var revertButton = document.createElement('button');
	    revertButton.textContent = 'Revert Selection';
	    revertButton.onclick = reverseSelections;
	    var selectAllButton = document.createElement('button');
	    selectAllButton.textContent = 'Select All';
	    selectAllButton.onclick = selectAllImages;
	    var downloadButton = document.createElement('button');
	    downloadButton.textContent = 'Download Selected Files';
	    downloadButton.style.backgroundColor = 'red';
	    downloadButton.onclick = downloadSelectedImages;

		// Create a textarea for displaying selected images
		var selectedImagesDiv = document.createElement('textarea');
		selectedImagesDiv.id = 'selectedImages';
		selectedImagesDiv.readOnly = true;


		// Append elements to the fixed container
		fixedContainer.appendChild(slider);
		fixedContainer.appendChild(sliderValue);
		document.body.insertBefore(fixedContainer, document.body.firstChild);
		document.body.insertBefore(selectedImagesDiv, fixedContainer.nextSibling);
	    fixedContainer.appendChild(containerWidthSlider);
	    fixedContainer.appendChild(blackSquare);
	    fixedContainer.appendChild(whiteSquare);
	    fixedContainer.appendChild(revertButton);
	    fixedContainer.appendChild(selectAllButton);
	    fixedContainer.appendChild(downloadButton);


	    // Speaker icon for muting videos
	    var speakerIcon = document.createElement('div');
	    speakerIcon.id = 'speakerIcon';
	    speakerIcon.textContent = '🔊';
	    fixedContainer.appendChild(speakerIcon);

	    var isMuted = false;

	    speakerIcon.addEventListener('click', function() {
	        isMuted = !isMuted;
	        speakerIcon.textContent = isMuted ? '🔇' : '🔊';

	        var videos = document.getElementsByTagName('video');
	        for (var i = 0; i < videos.length; i++) {
	            videos[i].muted = isMuted;
	        }
	    });

	    // Counting total and selected medias
	    var countDisplay = document.createElement('div');
		countDisplay.id = 'countDisplay';
		countDisplay.textContent = 'Total: ' + document.querySelectorAll('.image, .video').length + ' / Selected: ';
		var selectedCount = document.createElement('span');
		selectedCount.id = 'selectedCount';
		selectedCount.textContent = '0';
		countDisplay.appendChild(selectedCount);
		fixedContainer.appendChild(countDisplay);


	    // Add click event listeners to images and videos to toggle selection
		var medias = document.querySelectorAll('.image, .video');
		for(var i = 0; i < medias.length; i++) {
			medias[i].addEventListener('click', function(event) {
				if (!event.shiftKey) {
					toggleSelection(this);
				}
			});
		}


	    // Create a keyboard shortcut guide
	    var shortcutGuide = document.createElement('div');
	    shortcutGuide.id = 'shortcutGuide';
	    shortcutGuide.textContent = 'Shortcuts: Press SHIFT+Click (Open Modal), R+V (Revert Selection), CMD+A (Select All), D+L (Download Selected)';
	    document.body.insertBefore(shortcutGuide, document.body.firstChild);

	   

	    // Setup modal for image and video preview
	    var modal = document.getElementById('imageModal');
	    var modalImage = document.getElementById('modalImage');
	    var modalVideo = document.getElementById('modalVideo');
		var modalCaption = document.getElementById('modalCaption');

		// Add event listeners to images for modal
		var images = document.getElementsByClassName('image');
	    for (var i = 0; i < images.length; i++) {
	        images[i].addEventListener('click', function(event) {
	            if (event.shiftKey) {
	            	var imageName = decodeURIComponent(new URL(this.src).pathname.split('/').pop());
	                modal.style.display = "block";
	                document.body.style.overflow = 'hidden';
	                modalImage.src = imageName;
	                modalImage.style.display = "block";
	                modalVideo.style.display = "none";
	                modalCaption.textContent = imageName;


	                if (selectedImages.includes(imageName)) {
			            modalImage.classList.add('selected');
			        } else {
			            modalImage.classList.remove('selected');
			        }
	                
	            }
	        });
	    }

	    modalImage.addEventListener('click', function() {
	    	var imageName = decodeURIComponent(new URL(this.src).pathname.split('/').pop());
		    var correspondingImage = document.querySelector('img[src="' + imageName + '"]');
		    //alert(this.src.split('/').pop());
		    //alert(correspondingImage);
		    toggleSelection(correspondingImage);

		    if (selectedImages.includes(imageName)) {
		        this.classList.add('selected');
		    } else {
		        this.classList.remove('selected');
		    }
		});


    	// Add event listeners to videos for modal and hover play/pause
	    var videos = document.getElementsByClassName('video');
	    for (var j = 0; j < videos.length; j++) {
	        videos[j].addEventListener('mouseenter', function() {
	            this.play();
	        });
	        videos[j].addEventListener('mouseleave', function() {
	            this.pause();
	        });

	        videos[j].addEventListener('click', function(event) {
		        if (event.shiftKey) {
		            var videoName = decodeURIComponent(new URL(this.src).pathname.split('/').pop());
		            modal.style.display = "block";
		            document.body.style.overflow = 'hidden';
		            modalVideo.src = videoName;
		            modalVideo.style.display = "block";
		            modalImage.style.display = "none";
		            modalCaption.textContent = videoName;

		            if (selectedImages.includes(videoName)) {
		                modalVideo.classList.add('selected');
		            } else {
		                modalVideo.classList.remove('selected');
		            }
		        }
		    });
		}

		modalVideo.addEventListener('click', function() {
		    var videoName = decodeURIComponent(new URL(this.src).pathname.split('/').pop());
		    var correspondingVideo = document.querySelector('video[src="' + videoName + '"]');
		    toggleSelection(correspondingVideo);

		    if (selectedImages.includes(videoName)) {
		        this.classList.add('selected');
		    } else {
		        this.classList.remove('selected');
		    }
		});


	    // Close modal on click outside or Escape key
		window.addEventListener('click', function(event) {
	        if (event.target == modal || event.key === 'Escape') {
	            modal.style.display = "none";
	            document.body.style.overflow = '';
	            if (!modalVideo.paused) {
		            modalVideo.pause();
		        }
	        }
	    });
	    window.addEventListener('keydown', function(event) {
		    if (event.key === 'Escape') {
		        modal.style.display = "none";
		        document.body.style.overflow = '';
		        if (!modalVideo.paused) {
		            modalVideo.pause();
		        }
		    }
		});

	    // Change cursor on hover over images or videos based on SHIFT key
		document.addEventListener('mousemove', function(event) {
		    if (event.shiftKey) {
		        if (event.target.classList.contains('image') || event.target.classList.contains('video')) {
		            event.target.style.cursor = 'pointer';
		        }
		    } else {
		        if (event.target.classList.contains('image') || event.target.classList.contains('video')) {
		            event.target.style.cursor = 'default';
		        }
		    }
		});

		document.addEventListener('mousemove', function(event) {
		    if (event.ctrlKey) {
		        var target = event.target;
		        if ((target.classList.contains('image') || target.classList.contains('video')) && target !== lastHoveredMedia) {
		            toggleSelection(target);
		            lastHoveredMedia = target;
		        }
		    }
		});


		var medias = document.querySelectorAll('.image, .video');
		medias.forEach(function(media) {
		    media.addEventListener('mouseleave', function() {
		        lastHoveredMedia = null;
		    });
		});


		// Keyboard navigation for image scrolling
		function scrollToNextRow(direction) {
			var imagesPerRow = parseInt(document.getElementById('imageRange').value, 10);
			var firstImage = document.getElementsByClassName('image')[0];
			var rowHeight = firstImage.offsetHeight + parseInt(window.getComputedStyle(firstImage).marginBottom, 10);
			var currentPosition = window.pageYOffset || document.documentElement.scrollTop;
			var newRowPosition = direction === 'down' ? currentPosition + rowHeight + 15 : currentPosition - rowHeight - 15;
			window.scrollTo(0, newRowPosition);
		}

		// Keyboard shortcuts for selection actions
		document.addEventListener('keydown', function(e) {
			keysPressed[e.key] = true;
			if(keysPressed['Control'] || keysPressed['Meta']) {
				if(keysPressed['a']) {
					selectAllImages();
					e.preventDefault();
				}
			} else if(keysPressed['r'] && keysPressed['v']) {
				reverseSelections();
				e.preventDefault();
			} else if(keysPressed['d'] && keysPressed['l']) {
				if(Object.keys(keysPressed).length === 2 && keysPressed['d'] && keysPressed['l']) {
					downloadSelectedImages();
					e.preventDefault();
				}
			} else if(e.key === 'PageDown' || e.key === 'z' || e.key === 'Z') {
				scrollToNextRow('down');
				e.preventDefault();
			} else if(e.key === 'PageUp' || e.key === 'a' || e.key === 'A') {
				scrollToNextRow('up');
				e.preventDefault();
			}
		});
		document.addEventListener('keyup', function(e) {
			delete keysPressed[e.key];
		});



		// do next or prev in modal mode
		function getNextOrPreviousMedia(currentIndex, direction) {
		    var medias = document.querySelectorAll('.image, .video');

		    var newIndex;
		    if (direction === 'next') {
		        newIndex = currentIndex + 1;
		        if (newIndex >= medias.length) newIndex = 0;
		    } else {
		        newIndex = currentIndex - 1;
		        if (newIndex < 0) return currentIndex;
		    }

		    return medias[newIndex];
		}

		document.addEventListener('keydown', function(event) {
		    if (modal.style.display === 'block') {
		        if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') {
		            var currentMedia = modalImage.style.display === 'block' ? modalImage : modalVideo;

		            if (currentMedia === modalVideo && !modalVideo.paused) {
		                modalVideo.pause();
		            }

		            var currentFileName = decodeURIComponent(new URL(currentMedia.src).pathname.split('/').pop());
		            var currentIndex = Array.from(document.querySelectorAll('.image, .video')).indexOf(document.querySelector('[src$="' + currentFileName + '"]'));

		            var nextMedia = getNextOrPreviousMedia(currentIndex, event.key === 'ArrowRight' ? 'next' : 'previous');
		            if (!nextMedia) return;

		            var nextMediaFileName = decodeURIComponent(new URL(nextMedia.src).pathname.split('/').pop());

		            if (nextMedia.classList.contains('image')) {
		                modalImage.src = nextMediaFileName;
		                modalImage.style.display = "block";
		                modalVideo.style.display = "none";
		            } else if (nextMedia.classList.contains('video')) {
		                modalVideo.src = nextMediaFileName;
		                modalVideo.style.display = "block";
		                modalImage.style.display = "none";
		            }
		            modalCaption.textContent = nextMediaFileName;

		            // Update selection status
		            if (selectedImages.includes(nextMediaFileName)) {
		                modalImage.classList.add('selected');
		                modalVideo.classList.add('selected');
		            } else {
		                modalImage.classList.remove('selected');
		                modalVideo.classList.remove('selected');
		            }
		        }
		    }
		});


		
		// Initial update of image layout
		updateImages();

		// Delayed check for broken images
		setTimeout(function() {
	        var images = document.getElementsByClassName('image');
	        for (var i = 0; i < images.length; i++) {
	            if (!images[i].complete || images[i].naturalWidth === 0) {
	                images[i].style.height = 'fit-content';
	                images[i].style.position = 'relative';
	                images[i].style.bottom = '4px';
	            }
	        }
	    }, 2000);

	};