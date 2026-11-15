<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.foodloop.model.Donation" %>
<%@ page import="javax.servlet.http.HttpServletResponse" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    Object sessionUserId = session.getAttribute("userId");
    String sessionRole = String.valueOf(session.getAttribute("userRole"));

    if (sessionUserId == null || !"NGO".equalsIgnoreCase(sessionRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Donation donation = (Donation) request.getAttribute("donation");

    if (donation == null) {
        response.sendError(
            HttpServletResponse.SC_NOT_FOUND,
            "Donation details not found. Please open the donation from Available Food."
        );
        return;
    }

    String foodName = donation.getFoodName();
    String foodType = donation.getFoodType();
    String description = donation.getDescription();
    String pickupAddress = donation.getPickupAddress();
    String status = donation.getStatus();

    if (foodName == null) {
        foodName = "Unnamed Food";
    }

    if (foodType == null || foodType.trim().isEmpty()) {
        foodType = "Not specified";
    }

    if (description == null || description.trim().isEmpty()) {
        description = "No description provided by the donor.";
    }

    if (pickupAddress == null || pickupAddress.trim().isEmpty()) {
        pickupAddress = "Not specified";
    }

    if (status == null || status.trim().isEmpty()) {
        status = "Unknown";
    }

    String quantityText = String.valueOf(donation.getQuantity());
    String contextPath = request.getContextPath();

    String requestResult = request.getParameter("requestResult");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Food Details | FoodLoop</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/ngo.css">

    <script src="<%= contextPath %>/js/ngo.js" defer></script>
</head>

<body>

<div class="dashboard-layout">

    <aside class="sidebar">

        <a class="brand"
           href="<%= contextPath %>/ngo/dashboard">
            FoodLoop<span>.</span>
        </a>

        <p class="sidebar-label">NGO MENU</p>

        <nav>
            <a class="nav-link"
               href="<%= contextPath %>/ngo/dashboard">
                🏠 Dashboard
            </a>

            <a class="nav-link active"
               href="<%= contextPath %>/ngo/available-food">
                🍱 Available Food
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/ngo/my-requests.jsp">
                📩 My Requests
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/ngo/pickup-status.jsp">
                🚚 Pickup Status
            </a>
        </nav>

        <a class="nav-link logout-link"
           href="<%= contextPath %>/index.html">
            ↩ Back to Home
        </a>

    </aside>

    <main class="main-content">

        <header class="topbar">

            <div>
                <h1>Food Donation Details</h1>

                <p class="muted">
                    Review the donation before requesting it.
                </p>
            </div>

            <div class="profile-badge">N</div>

        </header>

        <% if ("success".equals(requestResult)) { %>

            <div class="form-message success" role="status">
                Your food request was submitted successfully!
                The donor can now see your request.
            </div>

        <% } else if ("error".equals(requestResult)) { %>

            <div class="form-message error" role="alert">
                Your request could not be submitted.
                The donation may no longer be available, or the requested
                quantity may exceed the available quantity.
                Please check the details and try again.
            </div>

        <% } else if ("invalid".equals(requestResult)) { %>

            <div class="form-message error" role="alert">
                Please enter a valid requested quantity.
            </div>

        <% } %>

        <section class="details-grid">

            <!-- FOOD DONATION DETAILS -->
            <article class="content-card">

                <div class="food-illustration">🍱</div>

                <p class="eyebrow">FOOD DONATION</p>

                <h2><%= escapeHtml(foodName) %></h2>

                <span class="status approved">
                    <%= escapeHtml(status) %>
                </span>

                <div class="detail-row">
                    <span>Donation ID</span>
                    <strong><%= donation.getDonationId() %></strong>
                </div>

                <div class="detail-row">
                    <span>Category</span>
                    <strong><%= escapeHtml(foodType) %></strong>
                </div>

                <div class="detail-row">
                    <span>Available Quantity</span>
                    <strong><%= escapeHtml(quantityText) %></strong>
                </div>

                <div class="detail-row">
                    <span>Prepared Date</span>
                    <strong>Refer to donation information</strong>
                </div>

                <div class="detail-row">
                    <span>Best Before</span>
                    <strong>Refer to donation expiry</strong>
                </div>

                <div class="detail-row">
                    <span>Pickup Deadline</span>
                    <strong>Check with the donor</strong>
                </div>

                <div class="detail-row">
                    <span>Donor</span>
                    <strong>Food Donor</strong>
                </div>

            </article>

            <!-- PICKUP INFORMATION -->
            <article class="content-card">

                <h2>Pickup Information</h2>

                <div class="detail-row">
                    <span>Pickup Location</span>
                    <strong><%= escapeHtml(pickupAddress) %></strong>
                </div>

                <div class="detail-row">
                    <span>Pickup Address</span>
                    <strong><%= escapeHtml(pickupAddress) %></strong>
                </div>

                <h3 class="subheading">About this Donation</h3>

                <p class="muted">
                    <%= escapeHtml(description) %>
                </p>

                <div class="form-note">
                    🌱 Confirm food safety and pickup arrangements
                    with the donor before collection.
                </div>

                <h3 class="subheading">Request Food</h3>

                <form id="foodRequestForm"
                      action="<%= contextPath %>/ngo/submit-request"
                      method="post">

                    <input type="hidden"
                           name="donationId"
                           value="<%= donation.getDonationId() %>">

                    <div class="form-group">

                        <label for="requestedQuantity">
                            Quantity Required *
                        </label>

                        <input type="number"
                               id="requestedQuantity"
                               name="requestedQuantity"
                               min="1"
                               max="<%= donation.getQuantity() %>"
                               step="1"
                               required>

                        <small id="requestedQuantityError"
                               class="error-message"></small>

                    </div>

                    <div class="form-group">

                        <label for="requestMessage">
                            Message to Donor
                        </label>

                        <textarea id="requestMessage"
                                  name="requestMessage"
                                  rows="3"
                                  placeholder="Tell the donor about your collection plan"></textarea>

                    </div>

                    <button type="submit"
                            class="btn btn-primary">
                        Submit Food Request
                    </button>

                    <p id="requestFormMessage"
                       class="form-message"
                       role="status"></p>

                </form>

                <a class="text-link back-link"
                   href="<%= contextPath %>/ngo/available-food">
                    ← Back to Available Food
                </a>

            </article>

        </section>

        <footer class="page-footer">
            © 2026 FoodLoop
        </footer>

    </main>

</div>

</body>
</html>