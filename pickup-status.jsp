
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%!
    private String escapeHtml(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value);

        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }

    /*
     * Escapes text for safe inclusion inside a JSON string.
     * Uses only standard Java; no external library is required.
     */
    private String escapeJson(Object value) {
        if (value == null) {
            return "";
        }

        String text = String.valueOf(value);
        StringBuilder result = new StringBuilder();

        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);

            switch (c) {
                case '"':
                    result.append("\\\"");
                    break;
                case '\\':
                    result.append("\\\\");
                    break;
                case '\b':
                    result.append("\\b");
                    break;
                case '\f':
                    result.append("\\f");
                    break;
                case '\n':
                    result.append("\\n");
                    break;
                case '\r':
                    result.append("\\r");
                    break;
                case '\t':
                    result.append("\\t");
                    break;
                case '<':
                    result.append("\\u003C");
                    break;
                case '>':
                    result.append("\\u003E");
                    break;
                case '&':
                    result.append("\\u0026");
                    break;
                default:
                    if (c < 0x20 || c == '\u2028' || c == '\u2029') {
                        result.append(String.format("\\u%04x", (int) c));
                    } else {
                        result.append(c);
                    }
                    break;
            }
        }

        return result.toString();
    }

    private String formatDate(Object value) {
        if (value == null) {
            return "Not available";
        }

        if (value instanceof Timestamp) {
            return new SimpleDateFormat("dd MMM yyyy, hh:mm a")
                    .format((Timestamp) value);
        }

        if (value instanceof java.util.Date) {
            return new SimpleDateFormat("dd MMM yyyy, hh:mm a")
                    .format((java.util.Date) value);
        }

        return escapeHtml(value);
    }

    private String statusClass(Object value) {
        if (value == null) {
            return "pending";
        }

        String status = String.valueOf(value).toUpperCase();

        if ("ACCEPTED".equals(status)) {
            return "approved";
        }

        if ("REJECTED".equals(status)) {
            return "rejected";
        }

        if ("COMPLETED".equals(status)) {
            return "completed";
        }

        return "pending";
    }

    private String statusLabel(Object value) {
        if (value == null) {
            return "Pending";
        }

        String status = String.valueOf(value).toUpperCase();

        if ("ACCEPTED".equals(status)) {
            return "Approved";
        }

        if ("REJECTED".equals(status)) {
            return "Rejected";
        }

        if ("COMPLETED".equals(status)) {
            return "Completed";
        }

        return "Pending";
    }
%>

<%
    List<Map<String, Object>> pickupRequests =
            (List<Map<String, Object>>) request.getAttribute("pickupRequests");

    if (pickupRequests == null) {
        pickupRequests = new java.util.ArrayList<Map<String, Object>>();
    }

    int mappedLocations = 0;

    for (Map<String, Object> item : pickupRequests) {
        Object latitudeValue = item.get("PICKUP_LATITUDE");
        Object longitudeValue = item.get("PICKUP_LONGITUDE");

        if (latitudeValue instanceof Number && longitudeValue instanceof Number) {
            double lat = ((Number) latitudeValue).doubleValue();
            double lng = ((Number) longitudeValue).doubleValue();

            if (Double.isFinite(lat) && Double.isFinite(lng)
                    && lat >= -90 && lat <= 90
                    && lng >= -180 && lng <= 180) {
                mappedLocations++;
            }
        }
    }

    String contextPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Pickup Status | FoodLoop</title>

    <link rel="stylesheet" href="<%= contextPath %>/css/ngo.css">

    <!-- Leaflet map -->
    <link rel="stylesheet"
        href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css">

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="<%= contextPath %>/js/ngo.js" defer></script>

    <style>
        .pickup-map {
            width: 100%;
            height: 420px;
            margin-top: 18px;
            border-radius: 14px;
            border: 1px solid #dce7d9;
            overflow: hidden;
            background: #f4f7ef;
        }

        .map-note {
            margin-top: 12px;
            padding: 12px 15px;
            background: #f1f7e9;
            border-radius: 10px;
            color: #496344;
            line-height: 1.6;
        }

        .pickup-card {
            padding: 20px 0;
            border-bottom: 1px solid #e5eadf;
        }

        .pickup-card:last-child {
            border-bottom: none;
        }

        .pickup-card h3 {
            margin-bottom: 8px;
        }

        .pickup-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
            gap: 12px;
            margin-top: 14px;
        }

        .pickup-detail {
            padding: 12px;
            border-radius: 10px;
            background: #f8faf5;
            overflow-wrap: anywhere;
        }

        .pickup-detail strong {
            display: block;
            margin-bottom: 5px;
        }

        .pickup-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 14px;
        }

        .pickup-actions a {
            display: inline-block;
            padding: 10px 14px;
            border-radius: 8px;
            background: #e7f2df;
            color: #285b32;
            text-decoration: none;
            font-weight: 600;
            cursor: pointer;
        }

        .pickup-actions a:hover {
            background: #d8eacb;
        }

        .empty-state {
            padding: 28px 12px;
            text-align: center;
            color: #61705d;
        }

        .status.rejected {
            background: #fde8e7;
            color: #a12d28;
        }

        .status.pending {
            background: #fff2d6;
            color: #8b6200;
        }

        .status.approved {
            background: #e2f4df;
            color: #286b35;
        }

        .status.completed {
            background: #dcefe9;
            color: #236b57;
        }

        .request-count {
            display: inline-block;
            margin-left: 6px;
            padding: 4px 9px;
            border-radius: 20px;
            background: #e7f2df;
            color: #285b32;
            font-size: 13px;
        }

        @media (max-width: 600px) {
            .pickup-map {
                height: 320px;
            }
        }
    </style>
</head>

<body>

<div class="dashboard-layout">

    <aside class="sidebar">
        <a class="brand" href="<%= contextPath %>/ngo/ngo-dashboard.jsp">
            FoodLoop<span>.</span>
        </a>

        <p class="sidebar-label">NGO MENU</p>

        <nav>
            <a class="nav-link"
               href="<%= contextPath %>/ngo/ngo-dashboard.jsp">
                🏠 Dashboard
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/ngo/available-food.jsp">
                🍱 Available Food
            </a>

            <a class="nav-link"
               href="<%= contextPath %>/ngo/my-requests.jsp">
                📩 My Requests
            </a>

            <a class="nav-link active"
               href="<%= contextPath %>/ngo/pickup-status">
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
                <h1>Pickup Status</h1>
                <p class="muted">
                    Track your food requests and find donor pickup locations.
                </p>
            </div>

            <div class="profile-badge">N</div>
        </header>

        <!-- Donor pickup locations -->
        <section class="content-card">
            <div class="section-heading">
                <div>
                    <h2>Donor Pickup Locations</h2>
                    <p class="muted">
                        Map markers use pickup coordinates saved by donors.
                    </p>
                </div>

                <span class="request-count">
                    <%= mappedLocations %> mapped location(s)
                </span>
            </div>

            <div id="pickupMap" class="pickup-map"></div>

            <div class="map-note" id="mapMessage" role="status">
                Loading donor pickup locations...
            </div>
        </section>

        <!-- Real pickup requests from the database -->
        <section class="content-card">
            <div class="section-heading">
                <div>
                    <h2>
                        Your Pickup Requests
                        <span class="request-count">
                            <%= pickupRequests.size() %>
                        </span>
                    </h2>

                    <p class="muted">
                        Details are retrieved from your FoodLoop requests.
                    </p>
                </div>
            </div>

            <% if (pickupRequests.isEmpty()) { %>

                <div class="empty-state">
                    <h3>No pickup requests found</h3>
                    <p>
                        When you request a food donation, its details and
                        donor pickup location will appear here.
                    </p>
                </div>

            <% } else { %>

                <% for (Map<String, Object> item : pickupRequests) {

                    Object requestId = item.get("REQUEST_ID");
                    Object donationId = item.get("DONATION_ID");
                    Object foodName = item.get("FOOD_NAME");
                    Object description = item.get("DESCRIPTION");
                    Object requestedQuantity = item.get("REQUESTED_QUANTITY");
                    Object status = item.get("STATUS");
                    Object requestDate = item.get("REQUEST_DATE");
                    Object pickupAddress = item.get("PICKUP_ADDRESS");
                    Object latitude = item.get("PICKUP_LATITUDE");
                    Object longitude = item.get("PICKUP_LONGITUDE");
                    Object foodType = item.get("FOOD_TYPE");
                    Object expiryTime = item.get("EXPIRY_TIME");

                    boolean hasCoordinates = false;
                    double lat = 0;
                    double lng = 0;

                    if (latitude instanceof Number && longitude instanceof Number) {
                        lat = ((Number) latitude).doubleValue();
                        lng = ((Number) longitude).doubleValue();

                        hasCoordinates =
                                Double.isFinite(lat)
                                && Double.isFinite(lng)
                                && lat >= -90 && lat <= 90
                                && lng >= -180 && lng <= 180;
                    }

                    String directionsUrl = null;

                    if (hasCoordinates) {
                        directionsUrl =
                                "https://www.google.com/maps/dir/?api=1&destination="
                                + lat + "," + lng;
                    }
                %>

                    <article class="pickup-card">

                        <div class="section-heading">
                            <div>
                                <h3><%= escapeHtml(foodName) %></h3>

                                <p class="muted">
                                    Request ID: FL-R<%= escapeHtml(requestId) %>
                                    &nbsp;|&nbsp;
                                    Donation ID: <%= escapeHtml(donationId) %>
                                </p>
                            </div>

                            <span class="status <%= statusClass(status) %>">
                                <%= statusLabel(status) %>
                            </span>
                        </div>

                        <div class="pickup-details">

                            <div class="pickup-detail">
                                <strong>Requested Quantity</strong>
                                <%= escapeHtml(requestedQuantity) %>
                            </div>

                            <div class="pickup-detail">
                                <strong>Food Type</strong>
                                <%= foodType == null || String.valueOf(foodType).trim().isEmpty()
                                        ? "Not specified"
                                        : escapeHtml(foodType) %>
                            </div>

                            <div class="pickup-detail">
                                <strong>Request Date</strong>
                                <%= formatDate(requestDate) %>
                            </div>

                            <div class="pickup-detail">
                                <strong>Food Expiry</strong>
                                <%= formatDate(expiryTime) %>
                            </div>

                            <div class="pickup-detail">
                                <strong>Donor Pickup Address</strong>
                                <%= pickupAddress == null
                                        || String.valueOf(pickupAddress).trim().isEmpty()
                                        ? "Pickup address not provided"
                                        : escapeHtml(pickupAddress) %>
                            </div>

                            <div class="pickup-detail">
                                <strong>Pickup Coordinates</strong>

                                <% if (hasCoordinates) { %>
                                    <%= lat %>, <%= lng %>
                                <% } else { %>
                                    Donor has not saved valid map coordinates.
                                <% } %>
                            </div>

                        </div>

                        <% if (description != null
                                && !String.valueOf(description).trim().isEmpty()) { %>

                            <p class="muted" style="margin-top: 12px;">
                                <strong>Description:</strong>
                                <%= escapeHtml(description) %>
                            </p>

                        <% } %>

                        <div class="pickup-actions">

                            <% if (hasCoordinates) { %>

                                <a href="<%= directionsUrl %>"
                                   target="_blank"
                                   rel="noopener noreferrer">
                                    📍 Get Directions
                                </a>

                                <a href="#pickupMap"
                                   class="show-on-map"
                                   data-lat="<%= lat %>"
                                   data-lng="<%= lng %>">
                                    🗺 Show on Map
                                </a>

                            <% } else { %>

                                <span class="muted">
                                    Map unavailable: this donation has no valid
                                    saved coordinates.
                                </span>

                            <% } %>

                        </div>

                    </article>

                <% } %>

            <% } %>

        </section>

        <footer class="page-footer">
            © 2026 FoodLoop
        </footer>

    </main>
</div>

<!-- JSON data for the map; no external JSON library is needed. -->
<script type="application/json" id="pickupLocationsData">
[
<%
    boolean firstLocation = true;

    for (Map<String, Object> item : pickupRequests) {

        Object latitude = item.get("PICKUP_LATITUDE");
        Object longitude = item.get("PICKUP_LONGITUDE");

        if (!(latitude instanceof Number)
                || !(longitude instanceof Number)) {
            continue;
        }

        double lat = ((Number) latitude).doubleValue();
        double lng = ((Number) longitude).doubleValue();

        if (!Double.isFinite(lat) || !Double.isFinite(lng)
                || lat < -90 || lat > 90
                || lng < -180 || lng > 180) {
            continue;
        }

        if (!firstLocation) {
            out.print(",");
        }

        firstLocation = false;

        Object food = item.get("FOOD_NAME");
        Object reqId = item.get("REQUEST_ID");
        Object address = item.get("PICKUP_ADDRESS");
%>
{
    "lat": <%= lat %>,
    "lng": <%= lng %>,
    "food": "<%= escapeJson(food == null ? "Food donation" : food) %>",
    "requestId": "<%= escapeJson(reqId) %>",
    "address": "<%= escapeJson(
        address == null || String.valueOf(address).trim().isEmpty()
            ? "Pickup address not provided"
            : address) %>"
}
<%
    }
%>
]
</script>

<script>
(function () {
    "use strict";

    var mapElement = document.getElementById("pickupMap");
    var mapMessage = document.getElementById("mapMessage");

    if (!mapElement || typeof L === "undefined") {
        if (mapMessage) {
            mapMessage.textContent =
                "The map could not load. Check your internet connection and try again.";
        }
        return;
    }

    var locationsElement =
        document.getElementById("pickupLocationsData");

    var locations = [];

    try {
        locations = JSON.parse(locationsElement.textContent || "[]");
    } catch (error) {
        mapMessage.textContent = "Unable to read pickup locations.";
        return;
    }

    // Default map view is only a fallback when no donor coordinates exist.
    var map = L.map("pickupMap").setView([16.5062, 80.6480], 11);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
            '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        maxZoom: 19
    }).addTo(map);

    var bounds = [];
    var markers = [];

    locations.forEach(function (location) {
        var marker = L.marker([location.lat, location.lng]).addTo(map);

        var popup = document.createElement("div");

        var title = document.createElement("strong");
        title.textContent = location.food || "Food donation";
        popup.appendChild(title);

        var requestParagraph = document.createElement("p");
        requestParagraph.textContent =
            "Request ID: FL-R" + location.requestId;
        popup.appendChild(requestParagraph);

        var addressParagraph = document.createElement("p");
        addressParagraph.textContent =
            location.address || "Address not provided";
        popup.appendChild(addressParagraph);

        var directions = document.createElement("a");
        directions.href =
            "https://www.google.com/maps/dir/?api=1&destination="
            + encodeURIComponent(location.lat + "," + location.lng);
        directions.target = "_blank";
        directions.rel = "noopener noreferrer";
        directions.textContent = "Get Directions";

        popup.appendChild(directions);

        marker.bindPopup(popup);

        bounds.push([location.lat, location.lng]);

        markers.push({
            lat: location.lat,
            lng: location.lng,
            marker: marker
        });
    });

    if (bounds.length > 0) {
        map.fitBounds(bounds, {
            padding: [35, 35],
            maxZoom: 15
        });

        mapMessage.textContent =
            locations.length
            + " donor pickup location(s) loaded from the database. "
            + "Select a marker to see food details and directions.";
    } else {
        mapMessage.textContent =
            "No donor coordinates are available for your requests yet. "
            + "The map will show markers after donors save pickup locations.";
    }

    document.querySelectorAll(".show-on-map").forEach(function (link) {
        link.addEventListener("click", function (event) {
            event.preventDefault();

            var lat = Number(this.getAttribute("data-lat"));
            var lng = Number(this.getAttribute("data-lng"));

            if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
                return;
            }

            map.setView([lat, lng], 16);

            markers.forEach(function (entry) {
                if (entry.lat === lat && entry.lng === lng) {
                    entry.marker.openPopup();
                }
            });

            mapElement.scrollIntoView({
                behavior: "smooth",
                block: "center"
            });
        });
    });

    window.setTimeout(function () {
        map.invalidateSize();
    }, 250);

})();
</script>

</body>
</html>
