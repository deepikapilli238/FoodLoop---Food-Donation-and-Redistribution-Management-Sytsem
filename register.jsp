<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // Logged-in users should not create another account from this page.
    if (session.getAttribute("fullName") != null) {
        response.sendRedirect("index.html");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Register | FoodLoop</title>

    <link rel="stylesheet" href="css/register.css">
</head>

<body>

<header class="auth-navbar">
    <a href="index.html" class="logo">Food<span>Loop</span></a>

    <a href="index.html" class="home-link">← Back to Home</a>
</header>

<main class="auth-container">

    <section class="auth-card">

        <div class="auth-icon">🌱</div>

        <h1>Join FoodLoop</h1>

        <p class="subtitle">
            Create your account and help reduce food waste.
        </p>

        <% if ("exists".equals(request.getParameter("error"))) { %>
            <div class="message error-message">
                An account with this email already exists.
            </div>
        <% } %>

        <% if ("1".equals(request.getParameter("error"))) { %>
            <div class="message error-message">
                Registration failed. Please check your details.
            </div>
        <% } %>

        <div id="clientError" class="message error-message" hidden></div>

        <form id="registerForm" action="register" method="post" novalidate>

            <div class="form-group">
                <label for="fullName">Full Name / Organization Name</label>

                <input
                    type="text"
                    id="fullName"
                    name="fullName"
                    placeholder="Enter your full name"
                    maxlength="100"
                    autocomplete="name"
                    required>

                <small class="field-error" id="nameError"></small>
            </div>

            <div class="form-group">
                <label for="email">Email Address</label>

                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Enter your email"
                    maxlength="150"
                    autocomplete="email"
                    required>

                <small class="field-error" id="emailError"></small>
            </div>

            <div class="form-group">
                <label for="password">Password</label>

                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Create a password"
                    minlength="8"
                    autocomplete="new-password"
                    required>

                <small class="field-help">
                    Minimum 8 characters; include uppercase, lowercase and a number.
                </small>

                <small class="field-error" id="passwordError"></small>
            </div>

            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>

                <input
                    type="password"
                    id="confirmPassword"
                    name="confirmPassword"
                    placeholder="Re-enter your password"
                    autocomplete="new-password"
                    required>

                <small class="field-error" id="confirmPasswordError"></small>
            </div>

            <div class="form-group">
                <label for="role">Choose Your Role</label>

                <select id="role" name="role" required>
                    <option value="">-- Select your role --</option>
                    <option value="DONOR">Food Donor</option>
                    <option value="NGO">NGO / Food Receiver</option>
                </select>

                <small class="field-error" id="roleError"></small>
            </div>

            <button type="submit" class="auth-button">
                Create My Account
            </button>

        </form>

        <p class="auth-footer">
            Already have an account?
            <a href="login.jsp">Login Here</a>
        </p>

    </section>

</main>

<footer class="auth-footer-bottom">
    <p>
        &copy; <span id="currentYear"></span>
        FoodLoop. Reducing waste, feeding hope.
    </p>
</footer>

<script src="js/register.js"></script>

</body>
</html>