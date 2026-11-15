<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    // Check login and donor role
    Object sessionUserId = session.getAttribute("userId");
    String sessionRole = String.valueOf(session.getAttribute("userRole"));

    if (sessionUserId == null ||
        !(sessionUserId instanceof Number) ||
        !"DONOR".equalsIgnoreCase(sessionRole)) {

        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String contextPath = request.getContextPath();

    String error = request.getParameter("error");
    String message = "";

    if ("invalid_expiry".equals(error) || "expiry".equals(error)) {
        message = "Please select an expiry date and time in the future.";
    } else if ("invalid_input".equals(error) || "missing".equals(error)) {
        message = "Please complete all required fields and try again.";
    } else if ("save_failed".equals(error) || "save".equals(error)) {
        message = "Your donation could not be saved. Please try again.";
    } else if ("quantity".equals(error)) {
        message = "Please enter a valid quantity greater than zero.";
    } else if ("location".equals(error)) {
        message = "The selected pickup location is invalid. Please select the location again.";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Donate Food | FoodLoop</title>

    <link rel="stylesheet"
          href="<%= contextPath %>/css/style.css">

    <!-- Leaflet interactive map styles -->
    <link rel="stylesheet"
          href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          crossorigin="">

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
            font-family: Arial, Helvetica, sans-serif;
            background: var(--cream);
            color: var(--text);
            line-height: 1.6;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        button,
        input,
        select,
        textarea {
            font: inherit;
        }

        /* Navigation */

        .donate-navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(255, 255, 255, 0.97);
            border-bottom: 1px solid var(--border);
        }

        .donate-nav-container {
            width: min(1160px, 90%);
            min-height: 76px;
            margin: auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
        }

        .donate-logo {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: var(--primary);
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -1px;
            white-space: nowrap;
        }

        .donate-logo-icon {
            display: grid;
            place-items: center;
            width: 43px;
            height: 43px;
            background: #dcfce7;
            border-radius: 13px;
            font-size: 25px;
        }

        .donate-nav-links {
            display: flex;
            align-items: center;
            gap: 26px;
        }

        .donate-nav-links a {
            color: #475569;
            font-size: 14px;
            font-weight: 600;
            transition: color 0.2s;
        }

        .donate-nav-links a:hover,
        .donate-nav-links a.active {
            color: var(--primary);
        }

        .donate-nav-links .logout-link {
            color: #b91c1c;
        }

        /* Main page */

        .donate-main {
            width: min(1160px, 90%);
            margin: auto;
            padding: 55px 0 80px;
        }

        .donate-hero {
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: 1.3fr 0.7fr;
            align-items: center;
            gap: 30px;
            padding: 48px;
            margin-bottom: 35px;
            border-radius: 25px;
            background:
                radial-gradient(circle at 90% 15%, #bbf7d0 0, transparent 32%),
                linear-gradient(135deg, #f0fdf4, #dcfce7);
        }

        .donate-badge {
            display: inline-block;
            margin-bottom: 17px;
            padding: 7px 14px;
            border: 1px solid #bbf7d0;
            border-radius: 30px;
            background: white;
            color: var(--primary);
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .donate-hero h1 {
            margin: 0 0 16px;
            color: #153b25;
            font-size: clamp(32px, 4vw, 48px);
            line-height: 1.15;
            letter-spacing: -1.5px;
        }

        .donate-hero h1 span {
            color: var(--primary);
        }

        .donate-hero p {
            max-width: 620px;
            margin: 0;
            color: var(--muted);
            font-size: 16px;
            line-height: 1.8;
        }

        .donate-hero-art {
            display: grid;
            place-items: center;
            min-height: 175px;
            font-size: 100px;
        }

        /* Form card */

        .donate-form-card {
            padding: 38px;
            border: 1px solid #e8f2e9;
            border-radius: 20px;
            background: var(--white);
            box-shadow: var(--shadow);
        }

        .donate-form-heading {
            margin-bottom: 30px;
        }

        .donate-section-label {
            display: inline-block;
            margin-bottom: 12px;
            padding: 6px 13px;
            border-radius: 30px;
            background: #dcfce7;
            color: var(--primary);
            font-size: 12px;
            font-weight: 700;
        }

        .donate-form-heading h2 {
            margin: 0 0 10px;
            color: #163b25;
            font-size: 30px;
            line-height: 1.3;
        }

        .donate-form-heading p {
            margin: 0;
            color: var(--muted);
            font-size: 15px;
        }

        /* Messages */

        .donate-error {
            margin-bottom: 25px;
            padding: 15px 18px;
            border: 1px solid #fecaca;
            border-radius: 10px;
            background: #fef2f2;
            color: #991b1b;
            font-size: 14px;
        }

        /* Form fields */

        .donate-form-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 24px;
        }

        .donate-field {
            display: flex;
            flex-direction: column;
            min-width: 0;
        }

        .donate-field.full-width {
            grid-column: 1 / -1;
        }

        .donate-field label {
            margin-bottom: 9px;
            color: #334155;
            font-size: 14px;
            font-weight: 700;
        }

        .required-mark {
            color: #dc2626;
        }

        .donate-field input,
        .donate-field select,
        .donate-field textarea {
            width: 100%;
            min-height: 50px;
            padding: 13px 15px;
            border: 1px solid #dbe3da;
            border-radius: 9px;
            outline: none;
            background: #fffefa;
            color: var(--text);
            font-size: 15px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .donate-field textarea {
            min-height: 115px;
            resize: vertical;
            line-height: 1.6;
        }

        .donate-field input:focus,
        .donate-field select:focus,
        .donate-field textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(21, 128, 61, 0.11);
        }

        .donate-field input::placeholder,
        .donate-field textarea::placeholder {
            color: #94a3b8;
        }

        .donate-hint {
            margin-top: 7px;
            color: var(--muted);
            font-size: 12px;
            line-height: 1.6;
        }

        /* Pickup location map */

        .donate-map-section {
            grid-column: 1 / -1;
            padding: 22px;
            border: 1px solid #d8eadb;
            border-radius: 14px;
            background: #fbfdf9;
        }

        .donate-map-heading {
            margin-bottom: 15px;
        }

        .donate-map-heading h3 {
            margin: 0 0 7px;
            color: #163b25;
            font-size: 20px;
        }

        .donate-map-heading p {
            margin: 0;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.7;
        }

        #pickupMap {
            width: 100%;
            height: 350px;
            border: 1px solid #dbe3da;
            border-radius: 12px;
            overflow: hidden;
            background: #edf5e9;
            z-index: 1;
        }

        .donate-map-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }

        .donate-map-btn {
            min-height: 42px;
            padding: 10px 16px;
            border: 1px solid #bbf7d0;
            border-radius: 8px;
            background: #fff;
            color: var(--primary-dark);
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.2s, transform 0.2s;
        }

        .donate-map-btn:hover {
            background: #dcfce7;
            transform: translateY(-1px);
        }

        .donate-map-btn-primary {
            border-color: var(--primary);
            background: var(--primary);
            color: white;
        }

        .donate-map-btn-primary:hover {
            background: var(--primary-dark);
        }

        .donate-map-status {
            margin: 13px 0 0;
            padding: 11px 13px;
            border-radius: 8px;
            background: #f0fdf4;
            color: #166534;
            font-size: 13px;
            overflow-wrap: anywhere;
        }

        .donate-map-status.warning {
            background: #fff7ed;
            color: #9a3412;
        }

        .donate-map-coordinates {
            display: flex;
            flex-wrap: wrap;
            gap: 8px 20px;
            margin-top: 10px;
            color: #475569;
            font-size: 12px;
        }

        .donate-map-coordinates strong {
            color: #166534;
        }

        /* Food safety box */

        .donate-safety {
            grid-column: 1 / -1;
            display: flex;
            align-items: flex-start;
            gap: 14px;
            padding: 18px;
            border: 1px solid #bbf7d0;
            border-radius: 12px;
            background: #f0fdf4;
        }

        .donate-safety-icon {
            font-size: 25px;
        }

        .donate-safety strong {
            display: block;
            margin-bottom: 4px;
            color: var(--primary-dark);
            font-size: 14px;
        }

        .donate-safety p {
            margin: 0;
            color: #64748b;
            font-size: 13px;
            line-height: 1.7;
        }

        /* Form buttons */

        .donate-form-actions {
            grid-column: 1 / -1;
            display: flex;
            flex-wrap: wrap;
            gap: 13px;
            padding-top: 5px;
        }

        .donate-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-height: 49px;
            padding: 13px 23px;
            border: 1px solid transparent;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.2s, background 0.2s;
        }

        .donate-btn:hover {
            transform: translateY(-2px);
        }

        .donate-btn-primary {
            background: var(--primary);
            color: white;
        }

        .donate-btn-primary:hover {
            background: var(--primary-dark);
        }

        .donate-btn-outline {
            border-color: #bbf7d0;
            background: white;
            color: var(--primary);
        }

        .donate-btn-outline:hover {
            background: #f0fdf4;
        }

        /* Bottom note */

        .donate-bottom-note {
            margin-top: 25px;
            color: var(--muted);
            font-size: 12px;
            text-align: center;
        }

        /* Responsive */

        @media (max-width: 760px) {
            .donate-nav-container {
                width: 92%;
                min-height: 70px;
                flex-wrap: wrap;
                padding: 12px 0;
            }

            .donate-logo {
                font-size: 23px;
            }

            .donate-logo-icon {
                width: 38px;
                height: 38px;
                font-size: 22px;
            }

            .donate-nav-links {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
                gap: 18px;
                padding-bottom: 8px;
            }

            .donate-main {
                width: 92%;
                padding: 30px 0 50px;
            }

            .donate-hero {
                grid-template-columns: 1fr;
                gap: 10px;
                padding: 30px 24px;
                border-radius: 18px;
            }

            .donate-hero h1 {
                font-size: 35px;
                letter-spacing: -1px;
            }

            .donate-hero-art {
                min-height: 100px;
                font-size: 70px;
            }

            .donate-form-card {
                padding: 25px 20px;
                border-radius: 16px;
            }

            .donate-form-heading h2 {
                font-size: 25px;
            }

            .donate-form-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .donate-field.full-width,
            .donate-map-section,
            .donate-safety,
            .donate-form-actions {
                grid-column: 1;
            }

            .donate-map-section {
                padding: 15px;
            }

            #pickupMap {
                height: 300px;
            }

            .donate-map-actions {
                flex-direction: column;
            }

            .donate-map-btn {
                width: 100%;
            }

            .donate-form-actions {
                flex-direction: column;
            }

            .donate-btn {
                width: 100%;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>

<body>

    <!-- Navigation -->
    <header class="donate-navbar">
        <div class="donate-nav-container">

            <a class="donate-logo"
               href="<%= contextPath %>/donor/donor-dashboard.jsp">

                <span class="donate-logo-icon">🌱</span>
                <span>FoodLoop</span>
            </a>

            <nav class="donate-nav-links" aria-label="Main navigation">
                <a href="<%= contextPath %>/donor/donor-dashboard.jsp">
                    Dashboard
                </a>

                <a href="<%= contextPath %>/donor/my-donations"
                   class="active">
                    My Donations
                </a>

                <a href="<%= contextPath %>/logout"
                   class="logout-link">
                    Logout
                </a>
            </nav>

        </div>
    </header>

    <main class="donate-main">

        <!-- Hero -->
        <section class="donate-hero">

            <div>
                <span class="donate-badge">
                    🌱 MAKE A DIFFERENCE
                </span>

                <h1>
                    Share Food,<br>
                    <span>Spread Hope.</span>
                </h1>

                <p>
                    Every meal shared is a step towards a world without
                    food waste. Donate your surplus food and help someone
                    in need.
                </p>
            </div>

            <div class="donate-hero-art" aria-hidden="true">
                🥗
            </div>

        </section>

        <!-- Donation form -->
        <section class="donate-form-card">

            <div class="donate-form-heading">
                <span class="donate-section-label">
                    NEW DONATION
                </span>

                <h2>Donate Surplus Food</h2>

                <p>
                    Tell us about the food you would like to share.
                    Your contribution can make a real difference.
                </p>
            </div>

            <% if (!message.isEmpty()) { %>
                <div class="donate-error" role="alert">
                    <%= message %>
                </div>
            <% } %>

            <form id="donationForm"
                  class="donate-form-grid"
                  action="<%= contextPath %>/donor/add-donation"
                  method="post">

                <!-- Food name -->
                <div class="donate-field">
                    <label for="foodName">
                        Food Name <span class="required-mark">*</span>
                    </label>

                    <input type="text"
                           id="foodName"
                           name="foodName"
                           maxlength="100"
                           placeholder="e.g. Vegetable rice"
                           autocomplete="off"
                           required>
                </div>

                <!-- Food category -->
                <div class="donate-field">
                    <label for="foodType">Food Category</label>

                    <select id="foodType" name="foodType">
                        <option value="">Choose a category</option>
                        <option value="Cooked Food">Cooked Food</option>
                        <option value="Fruits">Fruits</option>
                        <option value="Vegetables">Vegetables</option>
                        <option value="Bakery">Bakery</option>
                        <option value="Packaged Food">Packaged Food</option>
                        <option value="Dairy">Dairy</option>
                        <option value="Other">Other</option>
                    </select>
                </div>

                <!-- Quantity -->
                <div class="donate-field">
                    <label for="quantity">
                        Quantity <span class="required-mark">*</span>
                    </label>

                    <input type="number"
                           id="quantity"
                           name="quantity"
                           min="1"
                           step="1"
                           placeholder="Enter quantity"
                           required>

                    <span class="donate-hint">
                        Enter the number of portions or units.
                    </span>
                </div>

                <!-- Expiry -->
                <div class="donate-field">
                    <label for="expiryTime">Expiry Date &amp; Time</label>

                    <input type="datetime-local"
                           id="expiryTime"
                           name="expiryTime">

                    <span class="donate-hint">
                        If provided, choose a future date and time.
                    </span>
                </div>

                <!-- Pickup address -->
                <div class="donate-field full-width">
                    <label for="pickupAddress">
                        Pickup Address <span class="required-mark">*</span>
                    </label>

                    <textarea id="pickupAddress"
                              name="pickupAddress"
                              maxlength="300"
                              placeholder="Enter the complete pickup address"
                              required></textarea>

                    <span class="donate-hint">
                        Enter the address where the NGO should collect the food.
                    </span>
                </div>

                <!-- Interactive pickup map -->
                <section class="donate-map-section"
                         aria-labelledby="pickupMapHeading">

                    <div class="donate-map-heading">
                        <h3 id="pickupMapHeading">📍 Select Exact Pickup Location</h3>

                        <p>
                            Click on the map to place a marker, or drag the marker
                            to the exact pickup point. You can also use your current
                            location. Selecting a map location is optional.
                        </p>
                    </div>

                    <div id="pickupMap"
                         role="application"
                         aria-label="Interactive map for selecting food pickup location">
                    </div>

                    <div class="donate-map-actions">
                        <button type="button"
                                id="useMyLocation"
                                class="donate-map-btn donate-map-btn-primary">
                            📍 Use My Location
                        </button>

                        <button type="button"
                                id="clearMapSelection"
                                class="donate-map-btn">
                            Clear Map Selection
                        </button>
                    </div>

                    <p id="mapStatus"
                       class="donate-map-status"
                       role="status"
                       aria-live="polite">
                        Loading map... You can select a pickup point once the map loads.
                    </p>

                    <div class="donate-map-coordinates">
                        <span>
                            Latitude:
                            <strong id="latitudeDisplay">Not selected</strong>
                        </span>

                        <span>
                            Longitude:
                            <strong id="longitudeDisplay">Not selected</strong>
                        </span>
                    </div>

                    <!-- Names must match AddDonationServlet.java -->
                    <input type="hidden"
                           id="pickupLatitude"
                           name="pickupLatitude"
                           value="">

                    <input type="hidden"
                           id="pickupLongitude"
                           name="pickupLongitude"
                           value="">
                </section>

                <!-- Description -->
                <div class="donate-field full-width">
                    <label for="description">
                        Additional Information
                    </label>

                    <textarea id="description"
                              name="description"
                              maxlength="500"
                              placeholder="Add ingredients, storage instructions, or other details"></textarea>

                    <span class="donate-hint">
                        Mention any important information about the food.
                    </span>
                </div>

                <!-- Safety note -->
                <div class="donate-safety">
                    <span class="donate-safety-icon">🛡️</span>

                    <div>
                        <strong>Food safety comes first</strong>

                        <p>
                            Please donate food that is safe to consume.
                            Provide accurate information and ensure
                            appropriate storage before collection.
                        </p>
                    </div>
                </div>

                <!-- Actions -->
                <div class="donate-form-actions">

                    <button type="submit"
                            class="donate-btn donate-btn-primary">
                        🌱 Submit Donation
                    </button>

                    <a class="donate-btn donate-btn-outline"
                       href="<%= contextPath %>/donor/my-donations">
                        Cancel
                    </a>

                </div>

            </form>
        </section>

        <p class="donate-bottom-note">
            Every donation matters. Thank you for helping reduce food waste. 💚
        </p>

    </main>

    <!-- Leaflet map library -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            crossorigin=""></script>

    <script>
        (function () {
            "use strict";

            var mapElement = document.getElementById("pickupMap");
            var statusElement = document.getElementById("mapStatus");
            var latitudeInput = document.getElementById("pickupLatitude");
            var longitudeInput = document.getElementById("pickupLongitude");
            var latitudeDisplay = document.getElementById("latitudeDisplay");
            var longitudeDisplay = document.getElementById("longitudeDisplay");
            var locationButton = document.getElementById("useMyLocation");
            var clearButton = document.getElementById("clearMapSelection");
            var donationForm = document.getElementById("donationForm");

            var map = null;
            var marker = null;

            /*
             * Default map view: Vijayawada, Andhra Pradesh.
             * This is only the initial map view, not the donor's saved address
             * or current location. The donor can navigate to any location.
             */
            var defaultLatitude = 16.5062;
            var defaultLongitude = 80.6480;

            function setStatus(message, isWarning) {
                statusElement.textContent = message;

                if (isWarning) {
                    statusElement.classList.add("warning");
                } else {
                    statusElement.classList.remove("warning");
                }
            }

            function clearCoordinates() {
                latitudeInput.value = "";
                longitudeInput.value = "";

                latitudeDisplay.textContent = "Not selected";
                longitudeDisplay.textContent = "Not selected";
            }

            function formatCoordinate(value) {
                return Number(value).toFixed(7);
            }

            function selectLocation(latitude, longitude, zoomLevel) {
                if (!Number.isFinite(latitude)
                        || !Number.isFinite(longitude)
                        || latitude < -90
                        || latitude > 90
                        || longitude < -180
                        || longitude > 180) {

                    setStatus("Invalid location. Please select another point.", true);
                    return;
                }

                latitudeInput.value = formatCoordinate(latitude);
                longitudeInput.value = formatCoordinate(longitude);

                latitudeDisplay.textContent = latitudeInput.value;
                longitudeDisplay.textContent = longitudeInput.value;

                var selectedPoint = [latitude, longitude];

                if (!marker) {
                    marker = L.marker(selectedPoint, {
                        draggable: true,
                        autoPan: true
                    }).addTo(map);

                    marker.on("dragend", function () {
                        var point = marker.getLatLng();

                        selectLocation(point.lat, point.lng, map.getZoom());
                    });
                } else {
                    marker.setLatLng(selectedPoint);
                }

                if (typeof zoomLevel === "number") {
                    map.setView(selectedPoint, zoomLevel);
                }

                setStatus(
                    "Pickup location selected. You can drag the marker to adjust it.",
                    false
                );
            }

            function initializeMap() {
                if (typeof L === "undefined") {
                    setStatus(
                        "The map could not load. Check your internet connection and refresh the page. You can still enter the pickup address.",
                        true
                    );

                    locationButton.disabled = true;
                    clearButton.disabled = true;
                    return;
                }

                try {
                    map = L.map("pickupMap").setView(
                        [defaultLatitude, defaultLongitude],
                        12
                    );

                    L.tileLayer(
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        {
                            maxZoom: 19,
                            attribution:
                                '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener noreferrer">OpenStreetMap</a> contributors'
                        }
                    ).addTo(map);

                    map.on("click", function (event) {
                        selectLocation(
                            event.latlng.lat,
                            event.latlng.lng,
                            map.getZoom()
                        );
                    });

                    setStatus(
                        "Map ready. Click anywhere on the map to select the pickup location.",
                        false
                    );

                    /*
                     * Ensure Leaflet calculates the correct map dimensions
                     * after the form layout has rendered.
                     */
                    window.setTimeout(function () {
                        map.invalidateSize();
                    }, 200);

                } catch (error) {
                    console.error("Pickup map initialization failed:", error);

                    setStatus(
                        "Unable to initialize the map. You can still enter the pickup address.",
                        true
                    );
                }
            }

            locationButton.addEventListener("click", function () {
                if (!map) {
                    setStatus(
                        "The map is unavailable. Please check your internet connection.",
                        true
                    );
                    return;
                }

                if (!navigator.geolocation) {
                    setStatus(
                        "Your browser does not support location detection. Select the pickup point on the map instead.",
                        true
                    );
                    return;
                }

                locationButton.disabled = true;
                locationButton.textContent = "Finding your location...";

                setStatus(
                    "Waiting for location permission and GPS...",
                    false
                );

                navigator.geolocation.getCurrentPosition(
                    function (position) {
                        var latitude = position.coords.latitude;
                        var longitude = position.coords.longitude;

                        selectLocation(latitude, longitude, 17);

                        locationButton.disabled = false;
                        locationButton.textContent = "📍 Use My Location";
                    },

                    function (error) {
                        var errorMessage;

                        switch (error.code) {
                            case error.PERMISSION_DENIED:
                                errorMessage =
                                    "Location permission was denied. Allow location access in your browser or select a point manually.";
                                break;

                            case error.POSITION_UNAVAILABLE:
                                errorMessage =
                                    "Your location is currently unavailable. Try again or select a point manually.";
                                break;

                            case error.TIMEOUT:
                                errorMessage =
                                    "Finding your location took too long. Please try again or select a point manually.";
                                break;

                            default:
                                errorMessage =
                                    "Unable to find your location. Select a point manually on the map.";
                        }

                        setStatus(errorMessage, true);

                        locationButton.disabled = false;
                        locationButton.textContent = "📍 Use My Location";
                    },

                    {
                        enableHighAccuracy: true,
                        timeout: 15000,
                        maximumAge: 60000
                    }
                );
            });

            clearButton.addEventListener("click", function () {
                if (marker && map) {
                    map.removeLayer(marker);
                    marker = null;
                }

                clearCoordinates();

                setStatus(
                    "Map selection cleared. The pickup address is still required.",
                    false
                );
            });

            donationForm.addEventListener("submit", function (event) {
                var latitude = latitudeInput.value.trim();
                var longitude = longitudeInput.value.trim();

                /*
                 * Coordinates are optional, but both must be present
                 * together. The servlet also validates their values.
                 */
                if ((latitude === "") !== (longitude === "")) {
                    event.preventDefault();

                    setStatus(
                        "The pickup coordinates are incomplete. Please select the location again or clear the selection.",
                        true
                    );
                    return;
                }

                if (latitude !== "" && longitude !== "") {
                    var lat = Number(latitude);
                    var lng = Number(longitude);

                    if (!Number.isFinite(lat)
                            || !Number.isFinite(lng)
                            || lat < -90
                            || lat > 90
                            || lng < -180
                            || lng > 180) {

                        event.preventDefault();

                        setStatus(
                            "The selected pickup coordinates are invalid. Please select the location again.",
                            true
                        );
                    }
                }
            });

            initializeMap();
        })();
    </script>

</body>
</html>