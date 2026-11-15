document.addEventListener("DOMContentLoaded", function () {

    /*
     * ADD DONATION FORM
     * Frontend validation and demo submission only.
     * No database record is created by this JavaScript.
     */
    const donationForm = document.getElementById("donationForm");

    if (donationForm) {
        const formMessage = document.getElementById("formMessage");

        const fieldRules = {
            foodName: function (value) {
                return value.trim().length >= 2
                    ? ""
                    : "Enter a food name with at least 2 characters.";
            },

            foodType: function (value) {
                return value ? "" : "Select a food category.";
            },

            quantity: function (value) {
                return Number(value) > 0
                    ? ""
                    : "Quantity must be greater than zero.";
            },

            unit: function (value) {
                return value ? "" : "Select a quantity unit.";
            },

            preparedDate: function (value) {
                if (!value) return "Select the prepared date.";

                const selected = new Date(value + "T00:00:00");
                const today = new Date();
                today.setHours(0, 0, 0, 0);

                return selected <= today
                    ? ""
                    : "Prepared date cannot be in the future.";
            },

            expiryDate: function (value) {
                const prepared = document.getElementById("preparedDate").value;

                if (!value) return "Select the best-before or expiry date.";
                if (!prepared) return "Select the prepared date first.";

                return value >= prepared
                    ? ""
                    : "Expiry date cannot be before the prepared date.";
            },

            pickupTime: function (value) {
                if (!value) return "Select the pickup deadline.";

                return new Date(value) > new Date()
                    ? ""
                    : "Pickup deadline must be in the future.";
            },

            contactNumber: function (value) {
                return /^[6-9]\d{9}$/.test(value.trim())
                    ? ""
                    : "Enter a valid 10-digit Indian mobile number.";
            },

            address: function (value) {
                return value.trim().length >= 8
                    ? ""
                    : "Enter a complete pickup address.";
            }
        };

        function validateField(fieldName) {
            const field = document.getElementById(fieldName);
            const error = document.getElementById(fieldName + "Error");

            if (!field || !error) return true;

            const rule = fieldRules[fieldName];
            const message = rule ? rule(field.value) : "";

            error.textContent = message;
            field.classList.toggle("invalid", Boolean(message));
            field.setAttribute("aria-invalid", message ? "true" : "false");

            return !message;
        }

        Object.keys(fieldRules).forEach(function (fieldName) {
            const field = document.getElementById(fieldName);

            if (field) {
                field.addEventListener("blur", function () {
                    validateField(fieldName);
                });

                field.addEventListener("input", function () {
                    if (field.classList.contains("invalid")) {
                        validateField(fieldName);
                    }
                });

                field.addEventListener("change", function () {
                    if (field.classList.contains("invalid")) {
                        validateField(fieldName);
                    }
                });
            }
        });

        donationForm.addEventListener("reset", function () {
            window.setTimeout(function () {
                document.querySelectorAll(".error-message").forEach(function (element) {
                    element.textContent = "";
                });

                donationForm.querySelectorAll(".invalid").forEach(function (element) {
                    element.classList.remove("invalid");
                    element.removeAttribute("aria-invalid");
                });

                formMessage.textContent = "";
                formMessage.className = "form-message";
            }, 0);
        });

        donationForm.addEventListener("submit", function (event) {
            event.preventDefault();

            let valid = true;

            Object.keys(fieldRules).forEach(function (fieldName) {
                if (!validateField(fieldName)) {
                    valid = false;
                }
            });

            if (!valid) {
                formMessage.textContent = "Please correct the highlighted fields.";
                formMessage.className = "form-message error";

                const firstInvalid = donationForm.querySelector(".invalid");

                if (firstInvalid) {
                    firstInvalid.focus();
                }

                return;
            }

            formMessage.textContent =
                "Frontend validation successful! Backend integration is still pending; this donation has not been saved.";
            formMessage.className = "form-message success";
        });
    }

    /*
     * DONATION SEARCH AND STATUS FILTER
     */
    const donationSearch = document.getElementById("donationSearch");
    const statusFilter = document.getElementById("statusFilter");
    const donationsTable = document.getElementById("donationsTable");
    const noDonations = document.getElementById("noDonations");

    function filterDonations() {
        if (!donationsTable) return;

        const searchTerm = donationSearch
            ? donationSearch.value.toLowerCase().trim()
            : "";

        const selectedStatus = statusFilter
            ? statusFilter.value
            : "all";

        const rows = donationsTable.querySelectorAll("tbody tr");
        let visibleCount = 0;

        rows.forEach(function (row) {
            const rowText = row.textContent.toLowerCase();
            const rowStatus = row.dataset.status || "";

            const matchesSearch = rowText.includes(searchTerm);
            const matchesStatus =
                selectedStatus === "all" || rowStatus === selectedStatus;

            const visible = matchesSearch && matchesStatus;

            row.hidden = !visible;

            if (visible) {
                visibleCount++;
            }
        });

        if (noDonations) {
            noDonations.hidden = visibleCount !== 0;
        }
    }

    if (donationSearch) {
        donationSearch.addEventListener("input", filterDonations);
    }

    if (statusFilter) {
        statusFilter.addEventListener("change", filterDonations);
    }

    /*
     * DONATION REQUEST DEMO BUTTONS
     * These update only the visible page, not the database.
     */
    document.querySelectorAll("[data-request-action]").forEach(function (button) {
        button.addEventListener("click", function () {
            const action = button.dataset.requestAction;
            const requestCard = button.closest(".request-card");

            if (!requestCard) return;

            const confirmed = window.confirm(
                action === "accept"
                    ? "Accept this request in the frontend demo?"
                    : "Decline this request in the frontend demo?"
            );

            if (!confirmed) return;

            const status = requestCard.querySelector(".status");

            if (status) {
                if (action === "accept") {
                    status.textContent = "Accepted";
                    status.className = "status approved";
                } else {
                    status.textContent = "Declined";
                    status.className = "status rejected";
                }
            }

            requestCard.querySelectorAll("[data-request-action]").forEach(function (item) {
                item.disabled = true;
                item.style.opacity = "0.5";
                item.style.cursor = "not-allowed";
            });

            window.alert(
                "Demo only: the visible request status changed. No database record was updated."
            );
        });
    });

    /*
     * DEMO EDIT BUTTON
     */
    document.querySelectorAll("[data-demo-action='edit']").forEach(function (button) {
        button.addEventListener("click", function () {
            window.alert(
                "The edit feature will work after we add the donation-edit form and backend integration."
            );
        });
    });

});