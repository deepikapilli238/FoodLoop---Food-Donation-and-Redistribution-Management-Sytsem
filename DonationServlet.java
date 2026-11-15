
package com.foodloop.controller;

import com.foodloop.dao.DonationDAO;
import com.foodloop.model.Donation;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class DonationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));

        if (!"DONOR".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only donors can submit food donations.");
            return;
        }

        try {
            String foodName = request.getParameter("foodName");
            String description = request.getParameter("description");
            String quantityText = request.getParameter("quantity");
            String foodType = request.getParameter("foodType");
            String pickupAddress = request.getParameter("pickupAddress");
            String expiryText = request.getParameter("expiryTime");

            if (isBlank(foodName)
                    || isBlank(quantityText)
                    || isBlank(pickupAddress)) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/donor/add-donation.jsp?error=invalid_input");
                return;
            }

            int quantity;

            try {
                quantity = Integer.parseInt(quantityText.trim());
            } catch (NumberFormatException e) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/donor/add-donation.jsp?error=invalid_input");
                return;
            }

            if (quantity <= 0) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/donor/add-donation.jsp?error=invalid_input");
                return;
            }

            Timestamp expiryTimestamp = null;

            if (!isBlank(expiryText)) {
                try {
                    LocalDateTime expiryDateTime =
                            LocalDateTime.parse(expiryText.trim());

                    if (!expiryDateTime.isAfter(LocalDateTime.now())) {
                        response.sendRedirect(
                                request.getContextPath()
                                + "/donor/add-donation.jsp?error=invalid_expiry");
                        return;
                    }

                    expiryTimestamp = Timestamp.valueOf(expiryDateTime);

                } catch (DateTimeParseException e) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/donor/add-donation.jsp?error=invalid_expiry");
                    return;
                }
            }

            Object sessionUserId = session.getAttribute("userId");
            int donorId;

            try {
                if (sessionUserId instanceof Number) {
                    donorId = ((Number) sessionUserId).intValue();
                } else {
                    donorId = Integer.parseInt(
                            String.valueOf(sessionUserId));
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(
                        request.getContextPath() + "/login.jsp");
                return;
            }

            Donation donation = new Donation();

            donation.setDonorId(donorId);
            donation.setFoodName(foodName.trim());
            donation.setDescription(
                    description == null ? "" : description.trim());
            donation.setQuantity(quantity);
            donation.setFoodType(
                    isBlank(foodType) ? "Other" : foodType.trim());
            donation.setPickupAddress(pickupAddress.trim());
            donation.setExpiryTime(expiryTimestamp);

            System.out.println("FoodLoop: Saving donation");
            System.out.println("Donor ID: " + donorId);
            System.out.println("Food Name: " + foodName);
            System.out.println("Submitted Quantity: " + quantity);

            donationDAO.addDonation(donation);

            response.sendRedirect(
                    request.getContextPath()
                    + "/donor/add-donation.jsp?success=true");

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to save the food donation to the database.", e);
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
