document.addEventListener("DOMContentLoaded", function () {

    const form = document.getElementById("loginForm");
    const email = document.getElementById("email");
    const password = document.getElementById("password");

    const emailError = document.getElementById("emailError");
    const passwordError = document.getElementById("passwordError");
    const clientError = document.getElementById("clientError");

    const year = document.getElementById("currentYear");

    if (year) {
        year.textContent = new Date().getFullYear();
    }

    function showError(input, errorElement, message) {
        errorElement.textContent = message;
        input.classList.add("invalid");
        input.setAttribute("aria-invalid", "true");
    }

    function clearError(input, errorElement) {
        errorElement.textContent = "";
        input.classList.remove("invalid");
        input.removeAttribute("aria-invalid");
    }

    email.addEventListener("input", function () {
        clearError(email, emailError);
        clientError.hidden = true;
    });

    password.addEventListener("input", function () {
        clearError(password, passwordError);
        clientError.hidden = true;
    });

    form.addEventListener("submit", function (event) {

        let valid = true;

        clearError(email, emailError);
        clearError(password, passwordError);
        clientError.hidden = true;

        const emailValue = email.value.trim();
        const passwordValue = password.value;

        const emailPattern =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (emailValue === "") {
            showError(email, emailError, "Email is required.");
            valid = false;
        } else if (!emailPattern.test(emailValue)) {
            showError(email, emailError, "Enter a valid email address.");
            valid = false;
        }

        if (passwordValue.trim() === "") {
            showError(password, passwordError, "Password is required.");
            valid = false;
        }

        if (!valid) {
            event.preventDefault();

            if (email.classList.contains("invalid")) {
                email.focus();
            } else {
                password.focus();
            }
        }
    });

});