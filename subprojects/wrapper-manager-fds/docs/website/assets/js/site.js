(function() {
    // Set up shop for QoL code listing features.
    var codeListings = document.querySelectorAll("main .listingblock > .content, main .literalblock > .content");

    for (elem of codeListings) {
        var parent = elem.parentElement;

        var fullscreenButton = document.createElement("button");
        fullscreenButton.classList.add("listingblock__fullscreen-btn");
        fullscreenButton.ariaLabel = "{{ T "fullscreenButtonAriaLabel" }}";
        fullscreenButton.title = "{{ T "fullscreenButtonLabel" }}";
        fullscreenButton.ariaDescription = "{{ T "fullscreenButtonDescription" }}";
        fullscreenButton.innerHTML = `{{- partial "components/heroicon.html" (dict "id" "arrows-pointing-out") | safeHTML }}`;

        fullscreenButton.addEventListener("click", (event) => {
            const { target } = event;
            const parent = target.closest(".listingblock") || target.closest(".literalblock");
            if (!document.fullscreenElement) {
                parent.requestFullscreen();
            } else if (document.exitFullscreen) {
                document.exitFullscreen();
            }
        });

        var copyButton = document.createElement("button");
        copyButton.classList.add("listingblock__copy-btn");
        copyButton.ariaLabel = "{{ T "copyButtonAriaLabel" }}";
        copyButton.title = "{{ T "copyButtonLabel" }}";
        copyButton.ariaDescription = "{{ T "copyButtonDescription" }}";
        copyButton.innerHTML = `{{- partial "components/heroicon.html" (dict "id" "clipboard") }}`;

        copyButton.addEventListener("click", (event) => {
            const { target } = event;
            const parent = target.closest(".listingblock");
            const codeListing = parent.querySelector(".content");
            navigator.clipboard.writeText(codeListing.textContent.trim());
        });

        var buttonRow = document.createElement("div");
        buttonRow.classList.add("listingblock__btn-row");

        if (parent.classList.contains("listingblock")) {
            buttonRow.appendChild(copyButton);
        }

        buttonRow.appendChild(fullscreenButton);
        parent.appendChild(buttonRow);
    }
})()
