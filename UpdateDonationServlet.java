
package com.foodloop.controller;

import com.foodloop.dao.DonationDAO;
import com.foodloop.model.Donation;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/donor/update-donation")
public class UpdateDonationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DonationDAO donationDAO = new DonationDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        String role = String.valueOf(session.getAttribute("userRole"));

        if (!"DONOR".equalsIgnoreCase(role)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Only donors can update donations."
            );
            return;
        }

        int donorId;
        int donationId;

        try {
            donorId = Integer.parseInt(
                String.valueOf(session.getAttribute("userId"))
            );

            donationId = Integer.parseInt(
                request.getParameter("donationId")
            );

            if (donorId <= 0 || donationId <= 0) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid donor ID or donation ID."
                );
                return;
            }

        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "A valid donation ID is required."
            );
            return;
        }

        String foodName = request.getParameter("foodName");
        String description = request.getParameter("description");
        String quantityValue = request.getParameter("quantity");
        String foodType = request.getParameter("foodType");
        String pickupAddress = request.getParameter("pickupAddress");
        String expiryValue = request.getParameter("expiryTime");

        if (foodName == null || foodName.trim().isEmpty()
                || quantityValue == null || quantityValue.trim().isEmpty()
                || foodType == null || foodType.trim().isEmpty()
                || pickupAddress == null || pickupAddress.trim().isEmpty()
                || expiryValue == null || expiryValue.trim().isEmpty()) {

            response.sendRedirect(
                contextPath + "/donor/edit-donation?donationId="
                + donationId + "&message=validation"
            );
            return;
        }

        try {
            int quantity = Integer.parseInt(quantityValue.trim());

            if (quantity <= 0) {
                response.sendRedirect(
                    contextPath + "/donor/edit-donation?donationId="
                    + donationId + "&message=validation"
                );
                return;
            }

            LocalDateTime expiryDateTime =
                LocalDateTime.parse(expiryValue.trim());

            if (!expiryDateTime.isAfter(LocalDateTime.now())) {
                response.sendRedirect(
                    contextPath + "/donor/edit-donation?donationId="
                    + donationId + "&message=expiry"
                );
                return;
            }

            Donation donation = new Donation();

            donation.setDonationId(donationId);
            donation.setFoodName(foodName.trim());
            donation.setDescription(
                description == null ? "" : description.trim()
            );
            donation.setQuantity(quantity);
            donation.setFoodType(foodType.trim());
            donation.setPickupAddress(pickupAddress.trim());
            donation.setExpiryTime(Timestamp.valueOf(expiryDateTime));

            boolean updated =
                donationDAO.updateDonation(donation, donorId);

            if (updated) {
                response.sendRedirect(
                    contextPath + "/donor/my-donations.jsp?message=updated"
                );
            } else {
                response.sendRedirect(
                    contextPath + "/donor/edit-donation?donationId="
                    + donationId + "&message=failed"
                );
            }

        } catch (NumberFormatException | java.time.format.DateTimeParseException e) {
            response.sendRedirect(
                contextPath + "/donor/edit-donation?donationId="
                + donationId + "&message=validation"
            );

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to update donation.", e
            );
        }
    }
}
