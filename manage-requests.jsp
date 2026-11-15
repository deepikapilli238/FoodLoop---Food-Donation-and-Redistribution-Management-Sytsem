
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.foodloop.util.DBConnection" %>

<%!
    private String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }

        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String userRole = String.valueOf(session.getAttribute("userRole"));

    if (!"ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("userName");

    if (adminName == null || adminName.trim().isEmpty()) {
        adminName = "Admin";
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    boolean databaseError = false;
    int requestCount = 0;

    try {
        con = DBConnection.getConnection();

        if (con == null) {
            throw new SQLException("Database connection returned null.");
        }

        String sql =
            "SELECT FR.REQUEST_ID, " +
            "U.FULL_NAME AS NGO_NAME, " +
            "D.FOOD_NAME, " +
            "FR.REQUESTED_QUANTITY, " +
            "FR.REQUEST_DATE, " +
            "FR.STATUS " +
            "FROM FOOD_REQUESTS FR " +
            "LEFT JOIN USERS U ON FR.NGO_ID = U.USER_ID " +
            "LEFT JOIN DONATIONS D ON FR.DONATION_ID = D.DONATION_ID " +
            "ORDER BY FR.REQUEST_DATE DESC";

        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();

    } catch (Exception e) {
        databaseError = true;
        application.log("Error loading FoodLoop admin requests.", e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Manage Requests | FoodLoop Admin</title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/admin.css">
</head>

<body>

<div class="admin-layout">

    <!-- Sidebar -->
    <aside class="sidebar">

        <a class="brand"
           href="<%= request.getContextPath() %>/admin/dashboard.jsp">
            FoodLoop
            <span style="display:block; font-size:14px; font-weight:400;">
                Admin Panel
            </span>
        </a>

        <nav class="sidebar-nav">

            <a href="<%= request.getContextPath() %>/admin/dashboard.jsp">
                Dashboard
            </a>

            <a href="<%= request.getContextPath() %>/admin/manage-users.jsp">
                Manage Users
            </a>

            <a href="<%= request.getContextPath() %>/admin/manage-donations.jsp">
                Manage Donations
            </a>

            <a class="active"
               href="<%= request.getContextPath() %>/admin/manage-requests.jsp">
                Manage Requests
            </a>

            <a href="<%= request.getContextPath() %>/admin/statistics.jsp">
                Statistics
            </a>

            <a class="logout-link"
               href="<%= request.getContextPath() %>/logout">
                ↪ Logout
            </a>

        </nav>
    </aside>

    <!-- Main Content -->
    <main class="main-content">

        <header class="topbar">
            <div>
                <h1 class="page-title">Manage Requests</h1>
                <p class="page-subtitle">
                    View and monitor food requests submitted by NGOs.
                </p>
            </div>

            <div class="admin-profile">
                <div>
                    <div class="profile-name">
                        <%= escapeHtml(adminName) %>
                    </div>
                    <div class="profile-role">Administrator</div>
                </div>
            </div>
        </header>

        <section class="content-card">

            <div class="card-heading">
                <div>
                    <h2>Food Requests</h2>
                    <p class="card-description">
                        Requests recorded in the FoodLoop database.
                    </p>
                </div>
            </div>

            <% if (databaseError) { %>

                <div class="notice">
                    <strong>Unable to load requests.</strong>
                    <p>
                        Please check the Eclipse Tomcat Console for the
                        database error, then refresh this page.
                    </p>
                </div>

            <% } else { %>

                <!-- Search and Filter -->
                <div class="toolbar">

                    <input
                        type="text"
                        id="tableSearch"
                        class="search-input"
                        placeholder="Search request, NGO or food..."
                        aria-label="Search requests">

                    <select
                        id="statusFilter"
                        class="filter-select"
                        aria-label="Filter by request status">

                        <option value="ALL">All statuses</option>
                        <option value="PENDING">Pending</option>
                        <option value="ACCEPTED">Accepted</option>
                        <option value="REJECTED">Rejected</option>

                    </select>

                </div>

                <!-- Requests Table -->
                <div class="table-wrapper">

                    <table class="data-table" id="requestsTable">

                        <thead>
                            <tr>
                                <th>Request ID</th>
                                <th>NGO Name</th>
                                <th>Food Item</th>
                                <th>Quantity</th>
                                <th>Request Date</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody>

                        <%
                            if (rs != null) {
                                while (rs.next()) {
                                    requestCount++;

                                    Object id = rs.getObject("REQUEST_ID");
                                    Object ngo = rs.getObject("NGO_NAME");
                                    Object food = rs.getObject("FOOD_NAME");
                                    Object quantity = rs.getObject("REQUESTED_QUANTITY");
                                    Timestamp timestamp = rs.getTimestamp("REQUEST_DATE");
                                    Object statusObject = rs.getObject("STATUS");

                                    String status = statusObject == null
                                            ? "UNKNOWN"
                                            : statusObject.toString().trim().toUpperCase();

                                    String formattedDate = "N/A";

                                    if (timestamp != null) {
                                        formattedDate = new SimpleDateFormat(
                                            "dd MMM yyyy, hh:mm a"
                                        ).format(timestamp);
                                    }

                                    String searchText = (
                                        String.valueOf(id) + " " +
                                        (ngo == null ? "" : ngo.toString()) + " " +
                                        (food == null ? "" : food.toString()) + " " +
                                        status
                                    ).toLowerCase();
                        %>

                            <tr
                                data-status="<%= escapeHtml(status) %>"
                                data-search="<%= escapeHtml(searchText) %>">

                                <td><%= escapeHtml(id) %></td>

                                <td>
                                    <%= ngo == null
                                        ? "NGO unavailable"
                                        : escapeHtml(ngo) %>
                                </td>

                                <td>
                                    <%= food == null
                                        ? "Donation unavailable"
                                        : escapeHtml(food) %>
                                </td>

                                <td><%= escapeHtml(quantity) %></td>

                                <td><%= escapeHtml(formattedDate) %></td>

                                <td>
                                    <span class="badge <%
                                        if ("ACCEPTED".equals(status)) {
                                            out.print("badge-success");
                                        } else if ("REJECTED".equals(status)) {
                                            out.print("badge-danger");
                                        } else if ("PENDING".equals(status)) {
                                            out.print("badge-warning");
                                        } else {
                                            out.print("badge-info");
                                        }
                                    %>">
                                        <%= escapeHtml(status) %>
                                    </span>
                                </td>

                            </tr>

                        <%
                                }
                            }
                        %>

                        </tbody>
                    </table>

                    <div id="noResults" class="empty-state"
                         style="display:none;">
                        No requests match your search or selected status.
                    </div>

                    <% if (requestCount == 0) { %>
                        <div id="emptyRequests" class="empty-state">
                            <h3>No requests found</h3>
                            <p>
                                NGO food requests will appear here when
                                they are recorded in the database.
                            </p>
                        </div>
                    <% } %>

                </div>

            <% } %>

        </section>

        <footer class="page-footer">
            FoodLoop Admin Panel
        </footer>

    </main>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {

    const searchInput = document.getElementById("tableSearch");
    const statusFilter = document.getElementById("statusFilter");
    const table = document.getElementById("requestsTable");
    const noResults = document.getElementById("noResults");
    const emptyRequests = document.getElementById("emptyRequests");

    if (!searchInput || !statusFilter || !table) {
        return;
    }

    function filterRequests() {
        const searchText = searchInput.value.trim().toLowerCase();
        const selectedStatus = statusFilter.value;
        const rows = table.querySelectorAll("tbody tr");

        let visibleCount = 0;

        rows.forEach(function (row) {
            const rowSearch = row.getAttribute("data-search") || "";
            const rowStatus = row.getAttribute("data-status") || "";

            const matchesSearch = rowSearch.includes(searchText);
            const matchesStatus =
                selectedStatus === "ALL" || rowStatus === selectedStatus;

            const visible = matchesSearch && matchesStatus;

            row.style.display = visible ? "" : "none";

            if (visible) {
                visibleCount++;
            }
        });

        if (noResults) {
            noResults.style.display =
                rows.length > 0 && visibleCount === 0 ? "block" : "none";
        }

        if (emptyRequests) {
            emptyRequests.style.display =
                rows.length === 0 ? "block" : "none";
        }
    }

    searchInput.addEventListener("input", filterRequests);
    statusFilter.addEventListener("change", filterRequests);
});
</script>

<%
    if (rs != null) {
        try {
            rs.close();
        } catch (SQLException e) {
            application.log("Could not close request ResultSet.", e);
        }
    }

    if (ps != null) {
        try {
            ps.close();
        } catch (SQLException e) {
            application.log("Could not close request PreparedStatement.", e);
        }
    }

    if (con != null) {
        try {
            con.close();
        } catch (SQLException e) {
            application.log("Could not close request database connection.", e);
        }
    }
%>

</body>
</html>
