
document.addEventListener("DOMContentLoaded", function () {

    /*
     * AVAILABLE FOOD SEARCH AND CATEGORY FILTER
     */
    const foodSearch = document.getElementById("foodSearch");
    const foodCategoryFilter =
        document.getElementById("foodCategoryFilter");
    const availableFoodGrid =
        document.getElementById("availableFoodGrid");
    const noFoodResults =
        document.getElementById("noFoodResults");

    function filterFood() {
        if (!availableFoodGrid) return;

        const searchTerm = foodSearch
            ? foodSearch.value.toLowerCase().trim()
            : "";

        const selectedCategory = foodCategoryFilter
            ? foodCategoryFilter.value.toLowerCase().trim()
            : "all";

        const cards =
            availableFoodGrid.querySelectorAll(".food-card");

        let visibleCount = 0;

        cards.forEach(function (card) {
            const cardText = (card.textContent || "")
                .toLowerCase();

            const cardCategory = (
                card.dataset.category || ""
            ).toLowerCase().trim();

            const matchesSearch =
                cardText.includes(searchTerm);

            const matchesCategory =
                selectedCategory === "all" ||
                cardCategory === selectedCategory;

            const visible =
                matchesSearch && matchesCategory;

            // Explicit display style avoids CSS overriding hidden.
            card.style.display = visible ? "" : "none";

            if (visible) {
                visibleCount++;
            }
        });

        if (noFoodResults) {
            noFoodResults.style.display =
                visibleCount === 0 ? "" : "none";
        }
    }

    if (foodSearch) {
        foodSearch.addEventListener("input", filterFood);
    }

    if (foodCategoryFilter) {
        foodCategoryFilter.addEventListener("change", filterFood);
    }

    filterFood();


    /*
     * MY REQUESTS SEARCH AND STATUS FILTER
     */
    const requestSearch =
        document.getElementById("requestSearch");

    const requestStatusFilter =
        document.getElementById("requestStatusFilter");

    const requestsTable =
        document.getElementById("requestsTable");

    const noRequests =
        document.getElementById("noRequests");

    function normalizeStatus(status) {
        const value = (status || "")
            .toLowerCase()
            .trim();

        // Treat APPROVED and ACCEPTED as the same status.
        if (value === "approved") {
            return "accepted";
        }

        return value;
    }

    function filterRequests() {
        if (!requestsTable) {
            console.error(
                "FoodLoop: requestsTable was not found."
            );
            return;
        }

        const searchTerm = requestSearch
            ? requestSearch.value.toLowerCase().trim()
            : "";

        const selectedStatus = normalizeStatus(
            requestStatusFilter
                ? requestStatusFilter.value
                : "all"
        );

        const rows = requestsTable.querySelectorAll("tbody tr");

        let visibleCount = 0;

        rows.forEach(function (row) {

            /*
             * Search the complete row, including:
             * Request ID, food name, quantity, date and status.
             */
            const rowText = (row.textContent || "")
                .toLowerCase()
                .replace(/\s+/g, " ")
                .trim();

            /*
             * Read status from data-status first.
             * Fall back to the visible status label.
             */
            let rowStatus = row.getAttribute("data-status") || "";

            if (!rowStatus) {
                const statusElement =
                    row.querySelector(".status");

                if (statusElement) {
                    rowStatus = statusElement.textContent;
                }
            }

            rowStatus = normalizeStatus(rowStatus);

            const matchesSearch =
                rowText.includes(searchTerm);

            const matchesStatus =
                selectedStatus === "all" ||
                rowStatus === selectedStatus;

            const visible =
                matchesSearch && matchesStatus;

            /*
             * Explicitly set display instead of relying on hidden.
             * This helps when CSS rules override the hidden attribute.
             */
            row.style.display = visible ? "" : "none";

            if (visible) {
                visibleCount++;
            }
        });

        /*
         * Display the appropriate message.
         */
        if (noRequests) {
            if (rows.length === 0) {
                noRequests.textContent =
                    "You have not submitted any food requests yet.";

                noRequests.style.display = "";
            } else if (visibleCount === 0) {
                noRequests.textContent =
                    "No matching requests found.";

                noRequests.style.display = "";
            } else {
                noRequests.style.display = "none";
            }
        }

        console.log("FoodLoop request filter:", {
            search: searchTerm,
            status: selectedStatus,
            totalRows: rows.length,
            visibleRows: visibleCount
        });
    }

    if (requestSearch) {
        requestSearch.addEventListener("input", filterRequests);
    }

    if (requestStatusFilter) {
        requestStatusFilter.addEventListener("change", filterRequests);
    }

    // Run once on page load.
    filterRequests();


    /*
     * FOOD REQUEST FORM
     * Validate quantity and submit to the Java Servlet.
     */
    const foodRequestForm =
        document.getElementById("foodRequestForm");

    if (foodRequestForm) {
        const quantityInput =
            document.getElementById("requestedQuantity");

        const quantityError =
            document.getElementById("requestedQuantityError");

        const requestFormMessage =
            document.getElementById("requestFormMessage");

        function validateQuantity() {
            if (!quantityInput) return false;

            const quantityText = quantityInput.value.trim();
            const quantity = Number(quantityText);
            const maximum = Number(quantityInput.max);

            if (
                quantityText === "" ||
                !Number.isInteger(quantity) ||
                quantity < 1 ||
                !Number.isFinite(maximum) ||
                maximum < 1 ||
                quantity > maximum
            ) {
                if (quantityError) {
                    const maximumText =
                        Number.isFinite(maximum) && maximum >= 1
                            ? maximum
                            : "the available quantity";

                    quantityError.textContent =
                        "Enter a whole number between 1 and "
                        + maximumText + ".";
                }

                quantityInput.classList.add("invalid");
                quantityInput.setAttribute("aria-invalid", "true");

                return false;
            }

            if (quantityError) {
                quantityError.textContent = "";
            }

            quantityInput.classList.remove("invalid");
            quantityInput.setAttribute("aria-invalid", "false");

            return true;
        }

        if (quantityInput) {
            quantityInput.addEventListener("input", function () {
                if (quantityInput.classList.contains("invalid")) {
                    validateQuantity();
                }
            });
        }

        foodRequestForm.addEventListener("submit", function (event) {
            if (!validateQuantity()) {
                event.preventDefault();

                if (requestFormMessage) {
                    requestFormMessage.textContent =
                        "Please correct the requested quantity.";

                    requestFormMessage.className =
                        "form-message error";
                }

                if (quantityInput) {
                    quantityInput.focus();
                }

                return;
            }

            if (!window.confirm(
                "Submit this food request to the donor?"
            )) {
                event.preventDefault();
                return;
            }

            if (requestFormMessage) {
                requestFormMessage.textContent =
                    "Submitting your food request...";

                requestFormMessage.className = "form-message";
            }

            // Keep normal form submission enabled.
        });
    }
});
