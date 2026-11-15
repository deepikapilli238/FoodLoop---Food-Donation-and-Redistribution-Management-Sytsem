
package com.foodloop.controller;

import com.foodloop.dao.FoodRequestDAO;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ngo/pickup-status")
public class PickupStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FoodRequestDAO foodRequestDAO;

    @Override
    public void init() throws ServletException {
        foodRequestDAO = new FoodRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Only logged-in NGO users can access pickup status.
        if (session == null
                || session.getAttribute("userId") == null
                || session.getAttribute("userRole") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        String role = String.valueOf(
                session.getAttribute("userRole")
        );

        if (!"NGO".equalsIgnoreCase(role)) {
            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Only NGO users can access pickup status."
            );
            return;
        }

        Object userIdObject = session.getAttribute("userId");

        int ngoId;

        try {
            ngoId = Integer.parseInt(String.valueOf(userIdObject));
        } catch (NumberFormatException e) {
            session.invalidate();

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp"
            );
            return;
        }

        try {
            List<Map<String, Object>> pickupRequests =
                    foodRequestDAO.getPickupDetailsForNgo(ngoId);

            // TEMPORARY DEBUG LOGGING: Check donor coordinates in Eclipse Console.
            log("========== FOODLOOP PICKUP STATUS DEBUG ==========");
            log("Logged-in NGO ID: " + ngoId);
            log("Total pickup requests retrieved: " + pickupRequests.size());

            for (Map<String, Object> item : pickupRequests) {
                log("Food: " + item.get("FOOD_NAME")
                        + " | Request ID: " + item.get("REQUEST_ID")
                        + " | Donation ID: " + item.get("DONATION_ID")
                        + " | Latitude: " + item.get("PICKUP_LATITUDE")
                        + " | Longitude: " + item.get("PICKUP_LONGITUDE"));
            }

            log("=================================================");

            request.setAttribute("pickupRequests", pickupRequests);

            // Open the existing JSP with real database records.
            request.getRequestDispatcher(
                    "/ngo/pickup-status.jsp"
            ).forward(request, response);

        } catch (SQLException e) {

            log("Unable to load pickup status for NGO ID " + ngoId, e);

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load pickup status. Please try again."
            );
        }
    }
}
