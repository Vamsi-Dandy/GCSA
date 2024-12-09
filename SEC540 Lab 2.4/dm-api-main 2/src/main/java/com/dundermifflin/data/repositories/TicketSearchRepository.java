package com.dundermifflin.data.repositories;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;

import jakarta.inject.Inject;
import javax.sql.DataSource;

import org.springframework.stereotype.Repository;

import com.dundermifflin.data.config.PersistenceConfig;
import com.dundermifflin.data.entities.Customer;
import com.dundermifflin.data.entities.Employee;
import com.dundermifflin.data.entities.Ticket;

@Repository
public class TicketSearchRepository {

	@Inject
	private PersistenceConfig persistenceConfig;

	public ArrayList<Ticket> search(String submittedBy, String caller, String status, String dueDate)
			throws SQLException {

		ArrayList<Ticket> tickets = null;

		// Grab the data source from JPA
		DataSource ds = persistenceConfig.dataSource();

		// Query objects
		Statement stmt = null;
		String query = "select t.id, t.title, t.status, t.due_date, " +
				"t.opened_by_id, e.first_name as opened_by_first_name, e.last_name as opened_by_last_name, " +
				"t.customer_id, c.first_name as customer_first_name, c.last_name as customer_last_name " +
				"from ticket t " +
				"inner join employee e " +
				"on t.opened_by_id = e.id " +
				"inner join customer c " +
				"on t.customer_id = c.id " +
				"WHERE 1 = 1";

		if (submittedBy.length() > 0) {
			query = query + " AND CONCAT(e.first_name, ' ', e.last_name) LIKE CONCAT('%', '" + submittedBy + "', '%')";
		}

		if (caller.length() > 0) {
			query = query + " AND CONCAT(c.first_name, ' ', c.last_name) LIKE CONCAT('%', '" + caller + "', '%')";
		}

		if (status.length() > 0) {
			query = query + " AND t.status LIKE CONCAT('%', '" + status + "', '%')";
		}

		if (dueDate.length() > 0) {
			query = query + " AND t.due_date > TIMESTAMP('" + dueDate + "')";
		}

		ResultSet rs = null;

		try (Connection con = ds.getConnection()) {

			stmt = con.createStatement();
			rs = stmt.executeQuery(query);

			// Stand up the tickets list
			tickets = new ArrayList<Ticket>();

			while (rs.next()) {
				// Load the ticket entity object
				Ticket t = getTicketFromResultSet(rs);

				// Add the ticket to the list
				tickets.add(t);
			}
		}

		return tickets;
	}

	private Ticket getTicketFromResultSet(ResultSet rs) throws SQLException {
		Ticket t = new Ticket();
		t.setId(rs.getInt("id"));
		t.setTitle(rs.getString("title"));
		t.setStatus(rs.getString("status"));

		final Timestamp dueDate = rs.getTimestamp("due_date");
		if (!rs.wasNull())
			t.setDueDate(dueDate);

		// Add employee
		final int openedById = rs.getInt("opened_by_id");
		if (!rs.wasNull()) {
			Employee openedBy = new Employee();
			openedBy.setId(openedById);
			openedBy.setFirstName(rs.getString("opened_by_first_name"));
			openedBy.setLastName(rs.getString("opened_by_last_name"));
			t.setOpenedBy(openedBy);
		}

		// Add caller
		final int customerId = rs.getInt("customer_id");
		if (!rs.wasNull()) {
			Customer caller = new Customer();
			caller.setId(customerId);
			caller.setFirstName(rs.getString("customer_first_name"));
			caller.setLastName(rs.getString("customer_last_name"));
			t.setCustomer(caller);
		}
		return t;
	}
}
