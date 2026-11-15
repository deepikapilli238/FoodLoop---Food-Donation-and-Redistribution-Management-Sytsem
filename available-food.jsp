
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="com.foodloop.model.Donation" %>

<%
    List<Donation> availableDonations =
        (List<Donation>) request.getAttribute("availableDonations");

    int donationCount = availableDonations == null
            ? 0 : availableDonations.size();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Available Food | FoodLoop</title>

    <link rel="stylesheet" href="../css/ngo.css">
    <script src="../js/ngo.js" defer></script>
</head>

<body>

<div class="dashboard-layout">

    <aside class="sidebar">

        <a class="brand" href="ngo-dashboard.jsp">
            FoodLoop<span>.</span>
        </a>

        <p class="sidebar-label">NGO MENU</p>

        <nav>
            <a class="nav-link" href="ngo-dashboard.jsp">
                🏠 Dashboard
            </a>

            <a class="nav-link active"
               href="<%= request.getContextPath() %>/ngo/available-food">
                🍱 Available Food
            </a>

            <a class="nav-link" href="my-requests.jsp">
                📩 My Requests
            </a>

            <a class="nav-link" href="pickup-status.jsp">
                🚚 Pickup Status
            </a>
        </nav>

        <a class="nav-link logout-link" href="../index.html">
            ↩ Back to Home
        </a>

    </aside>

    <main class="main-content">

        <header class="topbar">

            <div>
                <h1>Available Food</h1>
                <p class="muted">
                    Discover food donations available for your organization.
                </p>
            </div>

            <div class="profile-badge">N</div>

        </header>

        <section class="content-card">

            <h2>Find Food Donations</h2>

            <p class="muted">
                Search by food name or filter by category.
            </p>

            <p class="muted">
                Total available donations: <%= donationCount %>
            </p>

            <div class="filter-bar">

                <input
                    type="search"
                    id="foodSearch"
                    placeholder="Search food donations..."
                    aria-label="Search food">

                <select
                    id="foodCategoryFilter"
                    aria-label="Filter by food category">

                    <option value="all">All Categories</option>
                    <option value="cooked food">Cooked Food</option>
                    <option value="bakery">Bakery</option>
                    <option value="fruits">Fruits</option>
                    <option value="vegetables">Vegetables</option>
                    <option value="packaged food">Packaged Food</option>

                </select>

            </div>

        </section>

        <section
            class="food-grid available-food-grid"
            id="availableFoodGrid">

            <% if (availableDonations == null ||
                   availableDonations.isEmpty()) { %>

                <p class="muted">
                    No available food donations found.
                </p>

            <% } else {
                for (Donation donation : availableDonations) {

                    String foodType = donation.getFoodType();

                    String category = foodType == null
                            ? "other"
                            : foodType.trim().toLowerCase();

                    String foodName = donation.getFoodName() == null
                            ? ""
                            : donation.getFoodName();

                    String pickupAddress =
                            donation.getPickupAddress() == null
                            ? "Not specified"
                            : donation.getPickupAddress();

                    String status = donation.getStatus() == null
                            ? ""
                            : donation.getStatus();
            %>

                <article
                    class="food-card"
                    data-category="<%= category %>">

                    <div class="food-image">🍱</div>

                    <div class="food-card-body">

                        <span class="food-category">
                            <%= foodType == null ? "Other" : foodType %>
                        </span>

                        <h3><%= foodName %></h3>

                        <p class="muted">
                            Quantity: <%= donation.getQuantity() %>
                        </p>

                        <p class="muted">
                            Pickup: <%= pickupAddress %>
                        </p>

                        <p class="muted">
                            Status: <%= status %>
                        </p>

                        <a class="btn btn-primary btn-block"
   href="<%= request.getContextPath() %>/ngo/food-details?donationId=<%= donation.getDonationId() %>">
    View Details
</a>

                    </div>

                </article>

            <%  }
               } %>

        </section>

        <p id="noFoodResults" class="empty-message" hidden>
            No matching food donations found.
        </p>

        <footer class="page-footer">
            © 2026 FoodLoop
        </footer>

    </main>

</div>

</body>
</html>
