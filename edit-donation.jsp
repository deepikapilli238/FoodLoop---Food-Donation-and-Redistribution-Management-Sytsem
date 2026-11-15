
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.foodloop.model.Donation" %>

<%
    String contextPath = request.getContextPath();

    Donation donation = (Donation) request.getAttribute("donation");

    if (donation == null) {
        response.sendRedirect(contextPath + "/donor/my-donations.jsp?error=notfound");
        return;
    }

    String expiryValue = "";

    if (donation.getExpiryTime() != null) {
        java.text.SimpleDateFormat formatter =
            new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        expiryValue = formatter.format(donation.getExpiryTime());
    }

    String message = request.getParameter("message");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Edit Donation | FoodLoop</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/donor.css">
    <script src="<%= contextPath %>/js/donor.js" defer></script>
</head>

<body>

<div class="dashboard-layout">

    <aside class="sidebar">

        <a class="brand"
           href="<%= contextPath %>/donor/donor-dashboard.jsp">
            FoodLoop<span>.</span>
        </a>

        <p class="sidebar-label">DONOR MENU</p>

        <nav>
            <a class="nav-link"
               href="<%= contextPath %>/donor/donor-dashboard.jsp">🏠 Dashboard</a>

            <a class="nav-link"
               href="<%= contextPath %>/donor/add-donation.jsp">➕ Add Donation</a>

            <a class="nav-link active"
               href="<%= contextPath %>/donor/my-donations.jsp">🍱 My Donations</a>

            <a class="nav-link"
               href="<%= contextPath %>/donor/donation-requests.jsp">📩 Donation Requests</a>

            <a class="nav-link"
               href="<%= contextPath %>/donor/donation-details.jsp">📋 Donation Details</a>
        </nav>

        <a class="nav-link logout-link"
           href="<%= contextPath %>/index.html">↩ Back to Home</a>

    </aside>

    <main class="main-content">

        <header class="topbar">
            <div>
                <h1>Edit Donation</h1>
                <p class="muted">Update your food donation details.</p>
            </div>

            <div class="profile-badge">D</div>
        </header>

        <% if ("invalid".equals(message)) { %>
            <div class="form-note">
                Please enter valid donation details.
            </div>
        <% } else if ("failed".equals(message)) { %>
            <div class="form-note">
                The donation could not be updated. It may no longer be available.
            </div>
        <% } %>

        <section class="content-card">

            <div class="section-heading">
                <div>
                    <h2>Update Donation #<%= donation.getDonationId() %></h2>
                    <p class="muted">
                        Make your changes and save them to FoodLoop.
                    </p>
                </div>
            </div>

            <form action="<%= contextPath %>/donor/update-donation"
                  method="post"
                  class="donation-form">

                <input type="hidden"
                       name="donationId"
                       value="<%= donation.getDonationId() %>">

                <div class="form-group">
                    <label for="foodName">Food Name</label>
                    <input type="text"
                           id="foodName"
                           name="foodName"
                           maxlength="100"
                           value="<%= donation.getFoodName() == null ? "" :
                               donation.getFoodName().replace("&", "&amp;")
                                   .replace("\"", "&quot;")
                                   .replace("<", "&lt;")
                                   .replace(">", "&gt;") %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea id="description"
                              name="description"
                              rows="4"
                              maxlength="1000"
                              required><%= donation.getDescription() == null ? "" :
                                  donation.getDescription().replace("&", "&amp;")
                                      .replace("<", "&lt;")
                                      .replace(">", "&gt;") %></textarea>
                </div>

                <div class="form-group">
                    <label for="quantity">Quantity</label>
                    <input type="number"
                           id="quantity"
                           name="quantity"
                           min="1"
                           value="<%= donation.getQuantity() %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="foodType">Food Type</label>
                    <input type="text"
                           id="foodType"
                           name="foodType"
                           maxlength="50"
                           value="<%= donation.getFoodType() == null ? "" :
                               donation.getFoodType().replace("&", "&amp;")
                                   .replace("\"", "&quot;")
                                   .replace("<", "&lt;")
                                   .replace(">", "&gt;") %>"
                           required>
                </div>

                <div class="form-group">
                    <label for="pickupAddress">Pickup Address</label>
                    <textarea id="pickupAddress"
                              name="pickupAddress"
                              rows="3"
                              maxlength="500"
                              required><%= donation.getPickupAddress() == null ? "" :
                                  donation.getPickupAddress().replace("&", "&amp;")
                                      .replace("<", "&lt;")
                                      .replace(">", "&gt;") %></textarea>
                </div>

                <div class="form-group">
                    <label for="expiryTime">Expiry Date and Time</label>
                    <input type="datetime-local"
                           id="expiryTime"
                           name="expiryTime"
                           value="<%= expiryValue %>"
                           required>
                </div>

                <div class="request-actions">
                    <a class="btn btn-outline"
                       href="<%= contextPath %>/donor/my-donations.jsp">
                        Cancel
                    </a>

                    <button type="submit" class="btn btn-primary">
                        Save Changes
                    </button>
                </div>

            </form>

        </section>

        <footer class="page-footer">
            © 2026 FoodLoop | Reducing Food Waste, Sharing Hope
        </footer>

    </main>

</div>

</body>
</html>
