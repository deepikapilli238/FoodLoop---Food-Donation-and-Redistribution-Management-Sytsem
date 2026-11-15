
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="com.foodloop.dao.DonationDAO" %>
<%@ page import="com.foodloop.model.Donation" %>

<%!
    public String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    public String formatExpiry(Timestamp timestamp) {
        if (timestamp == null) return "Not specified";
        return new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a")
                    .format(timestamp);
    }

    public String statusClass(String status) {
        if (status == null) return "status-default";
        if ("AVAILABLE".equalsIgnoreCase(status)) return "status-available";
        if ("REQUESTED".equalsIgnoreCase(status)) return "status-requested";
        if ("CLAIMED".equalsIgnoreCase(status)) return "status-claimed";
        if ("EXPIRED".equalsIgnoreCase(status)) return "status-expired";
        if ("COMPLETED".equalsIgnoreCase(status)) return "status-completed";
        return "status-default";
    }
%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    String userName = (String) session.getAttribute("userName");

    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    if (userRole == null || !"ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Donation> donations;

    try {
        donations = new DonationDAO().getAllDonations();
    } catch (Exception e) {
        donations = new java.util.ArrayList<Donation>();
        application.log("Error loading donations for admin", e);
    }

    String searchValue = request.getParameter("search");
    if (searchValue == null) searchValue = "";

    String statusValue = request.getParameter("status");
    if (statusValue == null) statusValue = "ALL";

    String deleteMessage = request.getParameter("deleted");
    String errorMessage = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Donations | FoodLoop Admin</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #f8f8ef;
            color: #174d38;
        }

        .dashboard-layout {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 260px;
            min-width: 260px;
            background: #164f38;
            color: #ffffff;
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
        }

        .brand {
            font-size: 28px;
            font-weight: bold;
            margin: 0 0 8px;
        }

        .brand-subtitle {
            color: #d4e6d8;
            font-size: 13px;
            margin-bottom: 38px;
        }

        .sidebar-heading {
            color: #b9d4c1;
            font-size: 11px;
            font-weight: bold;
            letter-spacing: 1.5px;
            margin: 0 0 14px 10px;
        }

        .nav-link {
            display: block;
            color: #edf5ed;
            text-decoration: none;
            padding: 13px 14px;
            margin-bottom: 7px;
            border-radius: 8px;
            font-size: 14px;
            transition: background 0.2s;
        }

        .nav-link:hover,
        .nav-link.active {
            background: #2b6c4d;
            color: #ffffff;
        }

        .logout-link {
            margin-top: auto;
            color: #ffffff;
        }

        .main-content {
            flex: 1;
            min-width: 0;
            padding: 34px;
        }

        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            margin-bottom: 28px;
        }

        .page-header h1 {
            font-size: 28px;
            margin: 0 0 8px;
            color: #164f38;
        }

        .page-header p {
            margin: 0;
            color: #758477;
            font-size: 14px;
        }

        .admin-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            background: #ffffff;
            border: 1px solid #e7e9dc;
            border-radius: 12px;
            padding: 10px 16px;
            white-space: nowrap;
        }

        .profile-icon {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: #e4efe3;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: #164f38;
        }

        .profile-name {
            font-size: 13px;
            font-weight: bold;
            color: #164f38;
        }

        .profile-role {
            font-size: 11px;
            color: #849083;
            margin-top: 4px;
        }

        .content-section {
            background: #ffffff;
            border: 1px solid #e9e9df;
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 4px 18px rgba(27, 65, 42, 0.04);
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 22px;
        }

        .section-header h2 {
            color: #164f38;
            font-size: 20px;
            margin: 0 0 6px;
        }

        .section-header p {
            color: #879084;
            font-size: 13px;
            margin: 0;
        }

        .donation-count {
            background: #e7f1e6;
            color: #205b3e;
            border-radius: 20px;
            padding: 8px 13px;
            font-size: 12px;
            font-weight: bold;
            white-space: nowrap;
        }

        .donation-toolbar {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
        }

        .search-input,
        .status-filter {
            border: 1px solid #dfe5da;
            background: #ffffff;
            border-radius: 8px;
            padding: 12px 14px;
            font-size: 13px;
            color: #254c37;
            outline: none;
        }

        .search-input {
            flex: 1;
            min-width: 100px;
        }

        .search-input:focus,
        .status-filter:focus {
            border-color: #43845d;
        }

        .status-filter {
            min-width: 155px;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        .donation-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }

        .donation-table th {
            text-align: left;
            padding: 15px 12px;
            background: #f6f8f1;
            color: #657565;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid #e8ebdf;
        }

        .donation-table td {
            padding: 16px 12px;
            font-size: 13px;
            color: #405648;
            border-bottom: 1px solid #edf0e8;
            vertical-align: middle;
        }

        .donation-table tbody tr:hover {
            background: #fbfcf8;
        }

        .food-name {
            color: #194c35;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .food-type {
            font-size: 11px;
            color: #8a9587;
        }

        .status {
            display: inline-block;
            border-radius: 20px;
            padding: 6px 10px;
            font-size: 11px;
            font-weight: bold;
            white-space: nowrap;
        }

        .status-available {
            background: #e0f3e4;
            color: #287443;
        }

        .status-requested {
            background: #fff0d4;
            color: #946514;
        }

        .status-claimed {
            background: #e1eaff;
            color: #315ca2;
        }

        .status-expired {
            background: #fde5e2;
            color: #ae3c34;
        }

        .status-completed {
            background: #e5e7eb;
            color: #4b5563;
        }

        .status-default {
            background: #eeeeea;
            color: #555e53;
        }

        .delete-form {
            margin: 0;
        }

        .delete-btn {
            background: #fff0ee;
            color: #b53e35;
            border: 1px solid #f4d3ce;
            padding: 8px 11px;
            border-radius: 7px;
            font-size: 12px;
            cursor: pointer;
        }

        .delete-btn:hover {
            background: #fbe0dc;
        }

        .empty-state {
            text-align: center;
            padding: 45px 20px;
            color: #879084;
        }

        .empty-state strong {
            display: block;
            color: #315b42;
            margin-bottom: 8px;
            font-size: 16px;
        }

        .notice {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 18px;
            font-size: 13px;
        }

        .notice-success {
            background: #e2f4e5;
            color: #246b3a;
        }

        .notice-error {
            background: #fde9e6;
            color: #a3362d;
        }

        .hidden-row {
            display: none;
        }

        @media (max-width: 900px) {
            .sidebar {
                width: 215px;
                min-width: 215px;
            }

            .main-content {
                padding: 22px;
            }

            .page-header {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (max-width: 600px) {
            .dashboard-layout {
                flex-direction: column;
            }

            .sidebar {
                width: 100%;
                min-width: 0;
                padding: 20px;
            }

            .brand-subtitle {
                margin-bottom: 20px;
            }

            .logout-link {
                margin-top: 10px;
            }

            .main-content {
                padding: 16px;
            }

            .content-section {
                padding: 16px;
            }

            .donation-toolbar {
                flex-direction: column;
            }

            .status-filter {
                width: 100%;
            }
        }
    </style>
</head>

<body>
<div class="dashboard-layout">

    <aside class="sidebar">
        <div class="brand">FoodLoop</div>
        <div class="brand-subtitle">Admin Control Panel</div>

        <div class="sidebar-heading">MAIN MENU</div>

        <a class="nav-link"
           href="<%= request.getContextPath() %>/admin/dashboard.jsp">
            ▦ Dashboard
        </a>

        <a class="nav-link"
           href="<%= request.getContextPath() %>/admin/manage-users.jsp">
            ♙ Manage Users
        </a>

        <a class="nav-link active"
           href="<%= request.getContextPath() %>/admin/manage-donations.jsp">
            ♧ Manage Donations
        </a>

        <a class="nav-link"
           href="<%= request.getContextPath() %>/admin/manage-requests.jsp">
            ⇄ Manage Requests
        </a>

        <a class="nav-link logout-link"
           href="<%= request.getContextPath() %>/logout">
            ↪ Logout
        </a>
    </aside>

    <main class="main-content">

        <header class="page-header">
            <div>
                <h1>Manage Donations</h1>
                <p>View and manage food donations across FoodLoop.</p>
            </div>

            <div class="admin-profile">
                <div class="profile-icon">
                    <%= userName != null && !userName.trim().isEmpty()
                            ? escapeHtml(userName.substring(0, 1).toUpperCase())
                            : "A" %>
                </div>
                <div>
                    <div class="profile-name">
                        <%= userName != null ? escapeHtml(userName) : "Administrator" %>
                    </div>
                    <div class="profile-role">Administrator</div>
                </div>
            </div>
        </header>

        <% if ("1".equals(deleteMessage)) { %>
            <div class="notice notice-success">
                Donation deleted successfully.
            </div>
        <% } %>

        <% if ("notfound".equals(errorMessage)) { %>
            <div class="notice notice-error">
                Donation was not found.
            </div>
        <% } else if ("deletefailed".equals(errorMessage)) { %>
            <div class="notice notice-error">
                Unable to delete the donation. Please check the server logs.
            </div>
        <% } %>

        <section class="content-section">

            <div class="section-header">
                <div>
                    <h2>All Donations</h2>
                    <p>Review donation details, expiry dates, and status.</p>
                </div>

                <div class="donation-count">
                    <%= donations.size() %> Donations
                </div>
            </div>

            <div class="donation-toolbar">
                <input
                    type="search"
                    id="searchInput"
                    class="search-input"
                    placeholder="Search food, donation ID, donor ID..."
                    aria-label="Search donations">

                <select id="statusFilter"
                        class="status-filter"
                        aria-label="Filter by donation status">
                    <option value="ALL">All Statuses</option>
                    <option value="AVAILABLE">Available</option>
                    <option value="REQUESTED">Requested</option>
                    <option value="CLAIMED">Claimed</option>
                    <option value="COMPLETED">Completed</option>
                    <option value="EXPIRED">Expired</option>
                </select>
            </div>

            <div class="table-wrapper">
                <table class="donation-table" id="donationTable">
                    <thead>
                    <tr>
                        <th>Donation ID</th>
                        <th>Food Item</th>
                        <th>Donor ID</th>
                        <th>Quantity</th>
                        <th>Expiry / Pickup</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% if (donations.isEmpty()) { %>
                        <tr>
                            <td colspan="7">
                                <div class="empty-state">
                                    <strong>No donations found</strong>
                                    Donations will appear here when available.
                                </div>
                            </td>
                        </tr>
                    <% } else {
                        for (Donation donation : donations) {
                            String foodName = donation.getFoodName() == null
                                    ? "" : donation.getFoodName();
                            String status = donation.getStatus() == null
                                    ? "" : donation.getStatus();
                    %>
                        <tr class="donation-row"
                            data-search="<%= escapeHtml(
                                (donation.getDonationId() + " " +
                                 foodName + " " +
                                 donation.getDonorId() + " " +
                                 donation.getFoodType() + " " +
                                 donation.getDescription() + " " +
                                 donation.getPickupAddress()).toLowerCase()
                            ) %>"
                            data-status="<%= escapeHtml(status.toUpperCase()) %>">

                            <td>#<%= donation.getDonationId() %></td>

                            <td>
                                <div class="food-name">
                                    <%= escapeHtml(foodName) %>
                                </div>
                                <div class="food-type">
                                    <%= escapeHtml(donation.getFoodType()) %>
                                </div>
                            </td>

                            <td><%= donation.getDonorId() %></td>

                            <td><%= donation.getQuantity() %></td>

                            <td>
                                <%= formatExpiry(donation.getExpiryTime()) %>
                            </td>

                            <td>
                                <span class="status <%= statusClass(status) %>">
                                    <%= escapeHtml(status) %>
                                </span>
                            </td>

                            <td>
                                <form class="delete-form"
                                      method="post"
                                      action="<%= request.getContextPath() %>/admin/delete-donation"
                                      onsubmit="return confirm('Are you sure you want to permanently delete this donation?');">

                                    <input type="hidden"
                                           name="donationId"
                                           value="<%= donation.getDonationId() %>">

                                    <button type="submit" class="delete-btn">
                                        Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <%  }
                       } %>
                    </tbody>
                </table>
            </div>

            <div id="noResults" class="empty-state" style="display:none;">
                <strong>No matching donations</strong>
                Try changing your search or status filter.
            </div>

        </section>
    </main>
</div>

<script>
    (function () {
        const searchInput = document.getElementById("searchInput");
        const statusFilter = document.getElementById("statusFilter");
        const rows = document.querySelectorAll(".donation-row");
        const noResults = document.getElementById("noResults");

        function filterDonations() {
            const searchText = searchInput.value.trim().toLowerCase();
            const selectedStatus = statusFilter.value;
            let visibleCount = 0;

            rows.forEach(function (row) {
                const searchableText = row.getAttribute("data-search") || "";
                const rowStatus = row.getAttribute("data-status") || "";

                const matchesSearch = searchableText.includes(searchText);
                const matchesStatus =
                    selectedStatus === "ALL" || rowStatus === selectedStatus;

                if (matchesSearch && matchesStatus) {
                    row.classList.remove("hidden-row");
                    visibleCount++;
                } else {
                    row.classList.add("hidden-row");
                }
            });

            noResults.style.display =
                rows.length > 0 && visibleCount === 0 ? "block" : "none";
        }

        searchInput.addEventListener("input", filterDonations);
        statusFilter.addEventListener("change", filterDonations);
    })();
</script>

</body>
</html>
