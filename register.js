document.addEventListener("DOMContentLoaded", function () {

    const form = document.getElementById("registerForm");

    const fullName = document.getElementById("fullName");
    const email = document.getElementById("email");
    const password = document.getElementById("password");
    const confirmPassword = document.getElementById("confirmPassword");
    const role = document.getElementById("role");

    const nameError = document.getElementById("nameError");
    const emailError = document.getElementById("emailError");
    const passwordError = document.getElementById("passwordError");
    const confirmPasswordError =
        document.getElementById("confirmPasswordError");
    const roleError = document.getElementById("roleError");

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

    const fields = [
        [fullName, nameError],
        [email, emailError],
        [password, passwordError],
        [confirmPassword, confirmPasswordError],
        [role, roleError]
    ];

    fields.forEach(function (field) {
        const input = field[0];
        const errorElement = field[1];

        input.addEventListener("input", function () {
            clearError(input, errorElement);
            clientError.hidden = true;
        });

        input.addEventListener("change", function () {
            clearError(input, errorElement);
            clientError.hidden = true;
        });
    });

    form.addEventListener("submit", function (event) {

        let valid = true;

        fields.forEach(function (field) {
            clearError(field[0], field[1]);
        });

        clientError.hidden = true;

        const nameValue = fullName.value.trim();
        const emailValue = email.value.trim();
        const passwordValue = password.value;
        const confirmValue = confirmPassword.value;

        const emailPattern =
            /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        const passwordPattern =
            /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

        if (nameValue.length < 2) {
            showError(
                fullName,
                nameError,
                "Enter a name containing at least 2 characters."
            );
            valid = false;
        }

        if (nameValue.length > 100) {
            showError(
                fullName,
                nameError,
                "Name must not exceed 100 characters."
            );
            valid = false;
        }

        if (emailValue === "") {
            showError(email, emailError, "Email is required.");
            valid = false;
        } else if (emailValue.length > 150 ||
                   !emailPattern.test(emailValue)) {
            showError(
                email,
                emailError,
                "Enter a valid email address."
            );
            valid = false;
        }

        if (passwordValue.length < 8) {
            showError(
                password,
                passwordError,
                "Password must contain at least 8 characters."
            );
            valid = false;
        } else if (!passwordPattern.test(passwordValue)) {
            showError(
                password,
                passwordError,
                "Include uppercase, lowercase and at least one number."
            );
            valid = false;
        }

        if (confirmValue === "") {
            showError(
                confirmPassword,
                confirmPasswordError,
                "Please confirm your password."
            );
            valid = false;
        } else if (passwordValue !== confirmValue) {
            showError(
                confirmPassword,
                confirmPasswordError,
                "Passwords do not match."
            );
            valid = false;
        }

        if (role.value !== "DONOR" && role.value !== "NGO") {
            showError(
                role,
                roleError,
                "Please select a valid role."
            );
            valid = false;
        }

        if (!valid) {
            event.preventDefault();

            const firstInvalid = form.querySelector(".invalid");

            if (firstInvalid) {
                firstInvalid.focus();
            }
        }
    });

});