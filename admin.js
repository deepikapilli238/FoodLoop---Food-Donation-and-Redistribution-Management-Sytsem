document.addEventListener("DOMContentLoaded", function () {

    const year = document.getElementById("currentYear");

    if (year) {
        year.textContent = new Date().getFullYear();
    }

    const menuButton = document.getElementById("mobileMenuButton");
    const sidebarNav = document.getElementById("sidebarNav");

    if (menuButton && sidebarNav) {
        menuButton.addEventListener("click", function () {
            const isOpen = sidebarNav.classList.toggle("open");

            menuButton.setAttribute("aria-expanded", String(isOpen));
        });
    }

    // Client-side search for the rows currently rendered in the table.
    const searchInput = document.getElementById("tableSearch");
    const table = document.querySelector(".data-table");
    const filterSelect = document.getElementById("statusFilter");

    function filterTable() {
        if (!table) {
            return;
        }

        const rows = table.querySelectorAll("tbody tr");
        const searchTerm = searchInput
            ? searchInput.value.toLowerCase().trim()
            : "";

        const statusFilter = filterSelect
            ? filterSelect.value.toLowerCase()
            : "";

        rows.forEach(function (row) {
            const rowText = row.textContent.toLowerCase();

            const statusCell = row.querySelector("[data-status]");
            const rowStatus = statusCell
                ? statusCell.dataset.status.toLowerCase()
                : "";

            const matchesSearch = rowText.includes(searchTerm);
            const matchesStatus =
                statusFilter === "" || rowStatus === statusFilter;

            row.hidden = !(matchesSearch && matchesStatus);
        });
    }

    if (searchInput) {
        searchInput.addEventListener("input", filterTable);
    }

    if (filterSelect) {
        filterSelect.addEventListener("change", filterTable);
    }

    // Confirmation for forms that explicitly opt in.
    document.querySelectorAll("form[data-confirm]").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            const message = form.dataset.confirm ||
                "Are you sure you want to continue?";

            if (!window.confirm(message)) {
                event.preventDefault();
            }
        });
    });

    // Prevent demo buttons from appearing to perform real database actions.
    document.querySelectorAll("[data-demo-action]").forEach(function (button) {
        button.addEventListener("click", function () {
            alert(
                "This action needs backend Servlet and database integration."
            );
        });
    });

});