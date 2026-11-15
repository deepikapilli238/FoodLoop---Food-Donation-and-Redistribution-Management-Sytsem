<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    // If already logged in, redirect to the appropriate dashboard.
    String loggedInUser = (String) session.getAttribute("fullName");
    String loggedInRole = (String) session.getAttribute("role");

    if (loggedInUser != null && loggedInRole != null) {
        if ("ADMIN".equalsIgnoreCase(loggedInRole)) {
            response.sendRedirect("admin/dashboard.jsp");
        } else if ("NGO".equalsIgnoreCase(loggedInRole)) {
            response.sendRedirect("ngo/dashboard.jsp");
        } else if ("DONOR".equalsIgnoreCase(loggedInRole)) {
            response.sendRedirect("donor/dashboard.jsp");
        }
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Login | FoodLoop</title>

    <link rel="stylesheet" href="css/login.css">
</head>

<body>

<header class="auth-navbar">
    <a href="index.html" class="logo">Food<span>Loop</span></a>

    <a href="index.html" class="home-link">← Back to Home</a>
</header>

<main class="auth-container">

    <section class="auth-card">

        <div class="auth-icon">🥗</div>

        <h1>Welcome Back!</h1>

        <p class="subtitle">
            Login to FoodLoop and help make a difference.
        </p>

        <% if ("1".equals(request.getParameter("registered"))) { %>
            <div class="message success-message">
                Registration successful! Please log in.
            </div>
        <% } %>

        <% if ("1".equals(request.getParameter("logout"))) { %>
            <div class="message success-message">
                You have been logged out successfully.
            </div>
        <% } %>

        <% if ("1".equals(request.getParameter("error"))) { %>
            <div class="message error-message">
                Invalid email or password.
            </div>
        <% } %>

        <% if ("1".equals(request.getParameter("unauthorized"))) { %>
            <div class="message error-message">
                Please log in to access that page.
            </div>
        <% } %>

        <div id="clientError" class="message error-message" hidden></div>

        <form id="loginForm" action="login" method="post" novalidate>

            <div class="form-group">
                <label for="email">Email Address</label>

                <input
                    type="email"
                    id="email"
                    name="email"
                    placeholder="Enter your email"
                    autocomplete="email"
                    maxlength="150"
                    required>

                <small class="field-error" id="emailError"></small>
            </div>

            <div class="form-group">
                <label for="password">Password</label>

                <input
                    type="password"
                    id="password"
                    name="password"
                    placeholder="Enter your password"
                    autocomplete="current-password"
                    required>

                <small class="field-error" id="passwordError"></small>
            </div>

            <button type="submit" class="auth-button">
                Login to FoodLoop
            </button>

        </form>

        <p class="auth-footer">
            Don't have an account?
            <a href="register.jsp">Register Now</a>
        </p>

    </section>

</main>

<footer class="auth-footer-bottom">
    <p>
        &copy; <span id="currentYear"></span>
        FoodLoop. Reducing waste, feeding hope.
    </p>
</footer>

<script src="js/login.js"></script>

</body>
</html>