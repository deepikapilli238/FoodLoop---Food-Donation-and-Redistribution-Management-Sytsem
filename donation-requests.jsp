<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>

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
    String contextPath = request.getContextPath();

    List<Map<String, Object>> donationRequests =
            (List<Map<String, Object>>) request.getAttribute("donationRequests");

    if (donationRequests == null) {
        donationRequests = new java.util.ArrayList<Map<String, Object>>();
    }

    int totalRequests = donationRequests.size();
    int pendingRequests = 0;
    int acceptedRequests = 0;
    int declinedRequests = 0;

    for (Map<String, Object> item : donationRequests) {
        String status = String.valueOf(item.get("STATUS"));

        if ("PENDING".equalsIgnoreCase(status)) {
            pendingRequests++;
        } else if ("ACCEPTED".equalsIgnoreCase(status)) {
            acceptedRequests++;
        } else if ("DECLINED".equalsIgnoreCase(status)
                || "REJECTED".equalsIgnoreCase(status)) {
            declinedRequests++;
        }
    }

    Object nameObject = session.getAttribute("userName");
    String donorName = nameObject == null
            ? "Donor"
            : String.valueOf(nameObject);
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Donation Requests | FoodLoop</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/style.css">

    <style>
        :root {
            --primary: #15803d;
            --primary-dark: #166534;
            --primary-light: #22c55e;
            --cream: #f8faf5;
            --white: #ffffff;
            --text: #1f2937;
            --muted: #64748b;
            --border: #e5e7eb;
            --shadow: 0 10px 35px rgba(21, 128, 61, 0.09);
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: var(--cream);
            color: var(--text);
            font-family: Arial, Helvetica, sans-serif;
            line-height: 1.6;
        }

        .donor-page {
            min-height: 100vh;
        }

        .donor-navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(255, 255, 255, 0.97);
            border-bottom: 1px solid var(--border);
        }

        .donor-nav-inner {
            width: min(1160px, 90%);
            min-height: 76px;
            margin: auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
        }

        .donor-brand {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: var(--primary);
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -1px;
            text-decoration: none;
            white-space: nowrap;
        }

        .donor-brand-icon {
            width: 43px;
            height: 43px;
            display: grid;
            place-items: center;
            border-radius: 13px;
            background: #dcfce7;
            font-size: 24px;
        }

        .donor-brand .brand-accent {
            color: #f59e0b;
        }

        .donor-nav-links {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            flex-wrap: wrap;
            gap: 10px;
        }

        .donor-nav-links a {
            color: #475569;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            padding: 9px 12px;
            border-radius: 8px;
            transition: background 0.2s, color 0.2s;
        }

        .donor-nav-links a:hover,
        .donor-nav-links a.active {
            color: var(--primary-dark);
            background: #dcfce7;
        }

        .donor-nav-links a.logout-link {
            color: #b91c1c;
        }

        .donor-container {
            width: min(1160px, 90%);
            margin: 0 auto;
            padding: 38px 0 60px;
        }

        .page-heading {
            margin-bottom: 26px;
        }

        .page-label {
            display: inline-block;
            color: var(--primary);
            background: #dcfce7;
            border-radius: 30px;
            padding: 6px 15px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.6px;
            margin-bottom: 12px;
        }

        .page-heading h1 {
            margin: 0 0 8px;
            color: #163b25;
            font-size: clamp(28px, 4vw, 38px);
            line-height: 1.2;
        }

        .page-heading p {
            margin: 0;
            color: var(--muted);
            font-size: 15px;
        }

        .welcome-panel {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 24px;
            padding: 30px;
            margin-bottom: 28px;
            background: linear-gradient(135deg, #166534, #15803d);
            color: #ffffff;
            border-radius: 20px;
            box-shadow: var(--shadow);
        }

        .welcome-panel h2 {
            color: #ffffff;
            font-size: clamp(23px, 3vw, 30px);
            line-height: 1.3;
            margin: 0 0 10px;
        }

        .welcome-panel p {
            max-width: 680px;
            margin: 0 0 20px;
            color: #e5f5e9;
        }

        .welcome-icon {
            flex-shrink: 0;
            display: grid;
            place-items: center;
            width: 85px;
            height: 85px;
            border-radius: 22px;
            background: rgba(255, 255, 255, 0.15);
            font-size: 44px;
        }

        .refresh-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 18px;
            border: 0;
            border-radius: 9px;
            background: #ffffff;
            color: var(--primary-dark);
            text-decoration: none;
            font-size: 14px;
            font-weight: 700;
            transition: transform 0.2s, background 0.2s;
        }

        .refresh-button:hover {
            background: #f0fdf4;
            transform: translateY(-1px);
        }

        .request-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 34px;
        }

        .request-stat-card {
            min-width: 0;
            padding: 22px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 16px;
            box-shadow: var(--shadow);
        }

        .stat-icon {
            display: grid;
            place-items: center;
            width: 44px;
            height: 44px;
            margin-bottom: 14px;
            border-radius: 12px;
            background: #dcfce7;
            font-size: 22px;
        }

        .request-stat-card h2 {
            margin: 0;
            color: var(--primary-dark);
            font-size: 30px;
            line-height: 1.2;
        }

        .request-stat-card p {
            margin: 7px 0 0;
            color: var(--muted);
            font-size: 14px;
        }

        .content-panel {
            padding: 28px;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 18px;
            box-shadow: var(--shadow);
        }

        .panel-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 22px;
        }

        .panel-heading h2 {
            margin: 0 0 5px;
            color: #163b25;
            font-size: 23px;
        }

        .panel-heading p {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
        }

        .request-list {
            display: grid;
            gap: 18px;
        }

        .request-card {
            min-width: 0;
            padding: 22px;
            border: 1px solid var(--border);
            border-radius: 14px;
            background: #ffffff;
            transition: box-shadow 0.2s, border-color 0.2s;
        }

        .request-card:hover {
            border-color: #bbf7d0;
            box-shadow: 0 8px 22px rgba(21, 128, 61, 0.07);
        }

        .request-card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 15px;
            padding-bottom: 17px;
            margin-bottom: 17px;
            border-bottom: 1px solid #f1f5f9;
        }

        .request-food {
            display: flex;
            align-items: center;
            gap: 13px;
            min-width: 0;
        }

        .food-icon {
            flex-shrink: 0;
            display: grid;
            place-items: center;
            width: 52px;
            height: 52px;
            border-radius: 14px;
            background: #f0fdf4;
            font-size: 26px;
        }

        .request-food h3 {
            margin: 0 0 4px;
            color: #163b25;
            font-size: 19px;
            overflow-wrap: anywhere;
        }

        .request-id {
            color: var(--muted);
            font-size: 13px;
        }

        .request-status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border-radius: 30px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            white-space: nowrap;
        }

        .status-pending {
            color: #92400e;
            background: #fef3c7;
        }

        .status-accepted {
            color: #166534;
            background: #dcfce7;
        }

        .status-declined,
        .status-rejected {
            color: #991b1b;
            background: #fee2e2;
        }

        .status-other {
            color: #475569;
            background: #f1f5f9;
        }

        .request-details {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
        }

        .detail-item {
            padding: 13px 15px;
            border-radius: 10px;
            background: #f8faf5;
        }

        .detail-label {
            display: block;
            margin-bottom: 4px;
            color: var(--muted);
            font-size: 12px;
            font-weight: 600;
        }

        .detail-value {
            display: block;
            color: #1f2937;
            font-size: 15px;
            font-weight: 700;
            overflow-wrap: anywhere;
        }

        /* Added only for Accept/Reject functionality */

        .request-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 20px;
            padding-top: 18px;
            border-top: 1px solid #f1f5f9;
        }

        .request-actions form {
            margin: 0;
        }

        .action-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 135px;
            padding: 10px 18px;
            border: none;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s, opacity 0.2s;
        }

        .action-button:hover {
            transform: translateY(-1px);
            opacity: 0.9;
        }

        .accept-button {
            color: #ffffff;
            background: #15803d;
        }

        .reject-button {
            color: #ffffff;
            background: #dc2626;
        }

        .request-result {
            padding: 13px 17px;
            margin-bottom: 20px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
        }

        .result-success {
            color: #166534;
            background: #dcfce7;
            border: 1px solid #bbf7d0;
        }

        .result-error {
            color: #991b1b;
            background: #fee2e2;
            border: 1px solid #fecaca;
        }

        .empty-state {
            padding: 42px 20px;
            text-align: center;
            background: #f8faf5;
            border: 1px dashed #cbd5c0;
            border-radius: 14px;
        }

        .empty-state .stat-icon {
            margin: 0 auto 15px;
        }

        .empty-state h3 {
            margin: 0 0 8px;
            color: #163b25;
            font-size: 21px;
        }

        .empty-state p {
            max-width: 480px;
            margin: 0 auto;
            color: var(--muted);
            font-size: 14px;
        }

        .donor-footer {
            padding: 22px 0;
            text-align: center;
            border-top: 1px solid var(--border);
            color: var(--muted);
            font-size: 13px;
            background: #ffffff;
        }

        .donor-footer span {
            color: var(--primary);
            font-weight: 700;
        }

        @media (max-width: 900px) {
            .request-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .donor-nav-inner {
                padding: 12px 0;
                align-items: flex-start;
                flex-direction: column;
                gap: 10px;
            }

            .donor-nav-links {
                justify-content: flex-start;
            }
        }

        @media (max-width: 600px) {
            .donor-container {
                width: 92%;
                padding-top: 26px;
            }

            .welcome-panel {
                padding: 22px;
            }

            .welcome-icon {
                display: none;
            }

            .request-stats {
                gap: 12px;
            }

            .request-stat-card {
                padding: 17px;
            }

            .content-panel {
                padding: 18px;
            }

            .request-card {
                padding: 16px;
            }

            .request-details {
                grid-template-columns: 1fr;
            }

            .request-card-top {
                align-items: flex-start;
            }

            .donor-brand {
                font-size: 23px;
            }
        }
    </style>
</head>

<body>

<div class="donor-page">

    <header class="donor-navbar">
        <div class="donor-nav-inner">

            <a class="donor-brand"
               href="<%= contextPath %>/donor/donor-dashboard.jsp">

                <span class="donor-brand-icon">🌿</span>
                <span>Food<span class="brand-accent">Loop</span></span>

            </a>

            <nav class="donor-nav-links">

                <a href="<%= contextPath %>/donor/donor-dashboard.jsp">
                    Dashboard
                </a>

                <a href="<%= contextPath %>/donor/add-donation.jsp">
                    Add Donation
                </a>

                <a href="<%= contextPath %>/donor/my-donations.jsp">
                    My Donations
                </a>

                <a class="active"
                   href="<%= contextPath %>/donor/donation-requests">
                    Donation Requests
                </a>

                <a href="<%= contextPath %>/donor/donation-details.jsp">
                    Details
                </a>

                <a class="logout-link"
                   href="<%= contextPath %>/logout">
                    Logout ↗
                </a>

            </nav>
        </div>
    </header>

    <main class="donor-container">

        <%-- Added request result messages --%>
        <%
            String result = request.getParameter("result");
        %>

        <% if ("accepted".equals(result)) { %>
            <div class="request-result result-success">
                Request accepted successfully. The NGO can now see the updated status.
            </div>
        <% } else if ("rejected".equals(result)) { %>
            <div class="request-result result-success">
                Request rejected successfully. The NGO can now see the updated status.
            </div>
        <% } else if ("unchanged".equals(result)) { %>
            <div class="request-result result-error">
                This request has already been processed or does not belong to your donations.
            </div>
        <% } else if ("invalid".equals(result)) { %>
            <div class="request-result result-error">
                Invalid request action. Please refresh and try again.
            </div>
        <% } %>

        <section class="page-heading">

            <span class="page-label">DONOR DASHBOARD</span>

            <h1>Donation Requests</h1>

            <p>
                Manage requests from NGOs interested in your surplus food.
            </p>

        </section>

        <section class="welcome-panel">

            <div>

                <h2>
                    Welcome back, <%= escapeHtml(donorName) %>! 🌱
                </h2>

                <p>
                    Your surplus food can make a difference.
                    Review requests submitted for your donations
                    and keep track of their status.
                </p>

                <a class="refresh-button"
                   href="<%= contextPath %>/donor/donation-requests">
                    ↻ Refresh Requests
                </a>

            </div>

            <div class="welcome-icon">🤝</div>

        </section>

        <section class="request-stats">

            <article class="request-stat-card">
                <div class="stat-icon">📩</div>
                <h2><%= totalRequests %></h2>
                <p>Total Requests</p>
            </article>

            <article class="request-stat-card">
                <div class="stat-icon">⏳</div>
                <h2><%= pendingRequests %></h2>
                <p>Pending Requests</p>
            </article>

            <article class="request-stat-card">
                <div class="stat-icon">✅</div>
                <h2><%= acceptedRequests %></h2>
                <p>Accepted Requests</p>
            </article>

            <article class="request-stat-card">
                <div class="stat-icon">❌</div>
                <h2><%= declinedRequests %></h2>
                <p>Declined Requests</p>
            </article>

        </section>

        <section class="content-panel">

            <div class="panel-heading">
                <div>
                    <h2>Requests From NGOs</h2>

                    <p>
                        All requests below belong to your donations.
                    </p>
                </div>
            </div>

            <div class="request-list">

                <% if (donationRequests.isEmpty()) { %>

                    <div class="empty-state">

                        <div class="stat-icon">📭</div>

                        <h3>No Requests Yet</h3>

                        <p>
                            When an NGO requests one of your food donations,
                            the request will appear here automatically.
                        </p>

                    </div>

                <% } else { %>

                    <% for (Map<String, Object> item : donationRequests) {

                        Object requestId = item.get("REQUEST_ID");
                        Object donationId = item.get("DONATION_ID");
                        Object ngoId = item.get("NGO_ID");
                        Object quantity = item.get("REQUESTED_QUANTITY");
                        Object foodName = item.get("FOOD_NAME");
                        Object requestDate = item.get("REQUEST_DATE");

                        String status = String.valueOf(item.get("STATUS"));

                        String statusClass = "status-other";

                        if ("PENDING".equalsIgnoreCase(status)) {
                            statusClass = "status-pending";
                        } else if ("ACCEPTED".equalsIgnoreCase(status)) {
                            statusClass = "status-accepted";
                        } else if ("DECLINED".equalsIgnoreCase(status)) {
                            statusClass = "status-declined";
                        } else if ("REJECTED".equalsIgnoreCase(status)) {
                            statusClass = "status-rejected";
                        }
                    %>

                        <article class="request-card">

                            <div class="request-card-top">

                                <div class="request-food">

                                    <div class="food-icon">🍱</div>

                                    <div>
                                        <h3>
                                            <%= escapeHtml(foodName) %>
                                        </h3>

                                        <span class="request-id">
                                            Request #<%= escapeHtml(requestId) %>
                                        </span>
                                    </div>

                                </div>

                                <span class="request-status <%= statusClass %>">
                                    <%= escapeHtml(status) %>
                                </span>

                            </div>

                            <div class="request-details">

                                <div class="detail-item">
                                    <span class="detail-label">NGO ID</span>
                                    <span class="detail-value">
                                        <%= escapeHtml(ngoId) %>
                                    </span>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">Donation ID</span>
                                    <span class="detail-value">
                                        <%= escapeHtml(donationId) %>
                                    </span>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">
                                        Requested Quantity
                                    </span>
                                    <span class="detail-value">
                                        <%= escapeHtml(quantity) %>
                                    </span>
                                </div>

                                <div class="detail-item">
                                    <span class="detail-label">Request Date</span>
                                    <span class="detail-value">
                                        <%
                                            if (requestDate instanceof Timestamp) {
                                                out.print(escapeHtml(
                                                    ((Timestamp) requestDate).toString()));
                                            } else {
                                                out.print(escapeHtml(requestDate));
                                            }
                                        %>
                                    </span>
                                </div>

                            </div>

                            <%-- Accept/Reject buttons appear only for PENDING requests --%>
                            <% if ("PENDING".equalsIgnoreCase(status)) { %>

                                <div class="request-actions">

                                    <form method="post"
                                          action="<%= contextPath %>/donor/request-action"
                                          onsubmit="return confirm('Are you sure you want to accept this request?');">

                                        <input type="hidden"
                                               name="requestId"
                                               value="<%= escapeHtml(requestId) %>">

                                        <input type="hidden"
                                               name="action"
                                               value="accept">

                                        <button type="submit"
                                                class="action-button accept-button">
                                            ✓ Accept Request
                                        </button>

                                    </form>

                                    <form method="post"
                                          action="<%= contextPath %>/donor/request-action"
                                          onsubmit="return confirm('Are you sure you want to reject this request?');">

                                        <input type="hidden"
                                               name="requestId"
                                               value="<%= escapeHtml(requestId) %>">

                                        <input type="hidden"
                                               name="action"
                                               value="reject">

                                        <button type="submit"
                                                class="action-button reject-button">
                                            ✕ Reject Request
                                        </button>

                                    </form>

                                </div>

                            <% } %>

                        </article>

                    <% } %>

                <% } %>

            </div>

        </section>

    </main>

    <footer class="donor-footer">
        Made with 💚 by <span>FoodLoop</span> — Every Meal Matters.
    </footer>

</div>

</body>
</html>