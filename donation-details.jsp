
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.foodloop.model.Donation" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.Timestamp" %>

<%
    Donation donation = (Donation) request.getAttribute("donation");

    if (donation == null) {
        response.sendRedirect(
            request.getContextPath() + "/donor/my-donations.jsp?message=notfound"
        );
        return;
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

    String expiryTime = "Not specified";

    if (donation.getExpiryTime() != null) {
        expiryTime = dateTimeFormat.format(donation.getExpiryTime());
    }

    String createdDate = "Not specified";
    Object createdAt = request.getAttribute("createdAt");

    if (createdAt instanceof Timestamp) {
        createdDate = dateFormat.format((Timestamp) createdAt);
    }

    String status = donation.getStatus() == null
            ? "UNKNOWN"
            : donation.getStatus();

    String statusClass = "pending";

    if ("AVAILABLE".equalsIgnoreCase(status)) {
        statusClass = "available";
    } else if ("CLAIMED".equalsIgnoreCase(status)
            || "COMPLETED".equalsIgnoreCase(status)) {
        statusClass = "completed";
    } else if ("EXPIRED".equalsIgnoreCase(status)
            || "REJECTED".equalsIgnoreCase(status)) {
        statusClass = "rejected";
    }

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Donation Details | FoodLoop</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/donor.css">
    <script src="<%= contextPath %>/js/donor.js" defer></script>
</head>

<body>

<div class="dashboard-layout">

    <aside class="sidebar">

        <a class="brand" href="<%= contextPath %>/donor/donor-dashboard.jsp">
            FoodLoop<span>.</span>
        </a>

        <p class="sidebar-label">DONOR MENU</p>

        <nav>
            <a class="nav-link"
               href="<%= contextPath %>/donor/donor-dashboard.jsp">
                🏠 Dashboard
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/donor/add-donation.jsp">
                ➕ Add Donation
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/donor/my-donations.jsp">
                🍱 My Donations
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/donor/donation-requests.jsp">
                📩 Donation Requests
            </a>

            <a class="nav-link active"
               href="<%= contextPath %>/donor/my-donations.jsp">
                📋 Donation Details
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
                <h1>Donation Details</h1>
                <p class="muted">
                    Review your donation information and status.
                </p>
            </div>

            <div class="profile-badge">D</div>
        </header>

        <div class="page-actions">

            <div>
                <h2>
                    Donation #<%= donation.getDonationId() %>
                </h2>

                <p class="muted">
                    Review the details of your donated food.
                </p>
            </div>

            <span class="status <%= statusClass %>">
                <%= status %>
            </span>

        </div>

        <section class="details-grid">

            <article class="content-card">

                <div class="food-illustration">🍱</div>

                <p class="eyebrow">DONATED FOOD</p>

                <h2>
                    <%= donation.getFoodName() == null
                            ? ""
                            : donation.getFoodName() %>
                </h2>

                <p class="muted">
                    <%= donation.getDescription() == null
                            || donation.getDescription().trim().isEmpty()
                            ? "No description provided."
                            : donation.getDescription() %>
                </p>

                <div class="detail-row">
                    <span>Donation ID</span>
                    <strong><%= donation.getDonationId() %></strong>
                </div>

                <div class="detail-row">
                    <span>Category</span>
                    <strong>
                        <%= donation.getFoodType() == null
                                ? "Not specified"
                                : donation.getFoodType() %>
                    </strong>
                </div>

                <div class="detail-row">
                    <span>Quantity</span>
                    <strong><%= donation.getQuantity() %></strong>
                </div>

                <div class="detail-row">
                    <span>Created Date</span>
                    <strong><%= createdDate %></strong>
                </div>

                <div class="detail-row">
                    <span>Best Before</span>
                    <strong><%= expiryTime %></strong>
                </div>

                <div class="detail-row">
                    <span>Donation Status</span>
                    <strong><%= status %></strong>
                </div>

            </article>

            <article class="content-card">

                <h2>Pickup Information</h2>

                <div class="detail-row">
                    <span>Pickup Address</span>
                    <strong>
                        <%= donation.getPickupAddress() == null
                                ? "Not specified"
                                : donation.getPickupAddress() %>
                    </strong>
                </div>

                <h3 class="subheading">Description</h3>

                <p class="muted">
                    <%= donation.getDescription() == null
                            || donation.getDescription().trim().isEmpty()
                            ? "No description provided."
                            : donation.getDescription() %>
                </p>

                <div class="form-note">
                    ℹ️ These details are loaded for the selected donation.
                </div>

                <div class="request-actions">

                    <a class="btn btn-outline"
                       href="<%= contextPath %>/donor/my-donations.jsp">
                        ← Back to Donations
                    </a>

                    <% if ("AVAILABLE".equalsIgnoreCase(status)) { %>

                        <a class="btn btn-primary"
                           href="<%= contextPath %>/donor/edit-donation?donationId=<%= donation.getDonationId() %>">
                            Edit Donation
                        </a>

                    <% } %>

                </div>

            </article>

        </section>

        <footer class="page-footer">
            © 2026 FoodLoop
        </footer>

    </main>

</div>

</body>
</html>
