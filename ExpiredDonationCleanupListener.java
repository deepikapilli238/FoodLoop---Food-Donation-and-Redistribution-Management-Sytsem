
package com.foodloop.controller;

import com.foodloop.util.DBConnection;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebListener
public class ExpiredDonationCleanupListener
        implements ServletContextListener {

    private static final Logger LOGGER =
            Logger.getLogger(ExpiredDonationCleanupListener.class.getName());

    private ScheduledExecutorService scheduler;

    // Run cleanup every five minutes.
    private static final long CLEANUP_INTERVAL_MINUTES = 5;

    @Override
    public void contextInitialized(ServletContextEvent event) {

        LOGGER.info("FoodLoop expiry cleanup listener started.");

        scheduler = Executors.newSingleThreadScheduledExecutor(runnable -> {
            Thread thread = new Thread(
                    runnable,
                    "FoodLoop-Expired-Donation-Cleanup"
            );

            thread.setDaemon(true);

            return thread;
        });

        // Run once immediately, then every five minutes.
        scheduler.scheduleWithFixedDelay(
                this::deleteExpiredDonations,
                0,
                CLEANUP_INTERVAL_MINUTES,
                TimeUnit.MINUTES
        );
    }

    private void deleteExpiredDonations() {

        Connection connection = null;

        try {
            connection = DBConnection.getConnection();

            if (connection == null) {
                LOGGER.warning(
                        "Expiry cleanup skipped: database connection is null."
                );
                return;
            }

            connection.setAutoCommit(false);

            int deletedRequests;
            int deletedDonations;

            /*
             * First delete requests belonging to expired donations.
             * SYSTIMESTAMP uses the Oracle database server's current time.
             */
            String deleteRequestsSql =
                    "DELETE FROM FOOD_REQUESTS " +
                    "WHERE DONATION_ID IN (" +
                    "    SELECT DONATION_ID " +
                    "    FROM DONATIONS " +
                    "    WHERE EXPIRY_TIME <= SYSTIMESTAMP" +
                    ")";

            try (PreparedStatement requestStatement =
                         connection.prepareStatement(deleteRequestsSql)) {

                deletedRequests = requestStatement.executeUpdate();
            }

            /*
             * Then delete the expired donations themselves.
             */
            String deleteDonationsSql =
                    "DELETE FROM DONATIONS " +
                    "WHERE EXPIRY_TIME <= SYSTIMESTAMP";

            try (PreparedStatement donationStatement =
                         connection.prepareStatement(deleteDonationsSql)) {

                deletedDonations = donationStatement.executeUpdate();
            }

            // Both deletions succeed together.
            connection.commit();

            if (deletedDonations > 0 || deletedRequests > 0) {
                LOGGER.info(
                        "Expiry cleanup completed. Deleted donations: "
                        + deletedDonations
                        + ", related requests: "
                        + deletedRequests
                );
            }

        } catch (Exception e) {

            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackException) {
                    LOGGER.log(
                            Level.SEVERE,
                            "Failed to roll back expiry cleanup.",
                            rollbackException
                    );
                }
            }

            LOGGER.log(
                    Level.SEVERE,
                    "FoodLoop expiry cleanup failed.",
                    e
            );

        } finally {

            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    LOGGER.log(
                            Level.WARNING,
                            "Could not close expiry cleanup connection.",
                            e
                    );
                }
            }
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {

        if (scheduler != null) {
            scheduler.shutdownNow();
        }

        LOGGER.info("FoodLoop expiry cleanup listener stopped.");
    }
}
