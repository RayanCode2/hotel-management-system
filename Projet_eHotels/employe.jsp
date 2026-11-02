<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // --- 1. SÉCURITÉ ET SESSION ---
    if ("true".equals(request.getParameter("logout"))) {
        session.removeAttribute("logged_hotel");
        response.sendRedirect("employe.jsp");
        return;
    }

    String formHotelId = request.getParameter("hotel_id");
    String formPassword = request.getParameter("password");
    String loginError = null;

    if (formHotelId != null && formPassword != null) {
        if ("1234".equals(formPassword)) {
            session.setAttribute("logged_hotel", Integer.parseInt(formHotelId));
            response.sendRedirect("employe.jsp");
            return;
        } else {
            loginError = "❌ Mot de passe incorrect.";
        }
    }

    Integer loggedHotel = (Integer) session.getAttribute("logged_hotel");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Interface Employé - Gestion e-Hotels</title>
    <style>
        body { font-family: sans-serif; margin: 30px; background-color: #f4f4f9; }
        .card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h2 { color: #333; border-bottom: 2px solid #28a745; padding-bottom: 10px; }
        input, select { padding: 8px; margin: 5px 0; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
        button { padding: 8px 12px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight:bold;}
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #343a40; color: white; }
        .btn-annuler { background-color: #d9534f; color: white; padding: 5px 10px; text-decoration: none; border-radius: 4px; font-size: 12px; }
        .btn-checkin { background-color: #007BFF; color: white; padding: 5px 10px; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; }
        .badge-attente { background-color: #ffc107; color: black; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold;}
        .badge-occupe { background-color: #28a745; color: white; padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold;}
        .header-top { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #ddd; padding-bottom: 10px; margin-bottom: 20px;}
        .form-row { display: grid; gap: 10px; margin-bottom: 10px; }
        .input-group label { font-size: 11px; font-weight: bold; color: #555; display: block; margin-bottom: -3px; }
    </style>
</head>
<body>

    <% if (loggedHotel == null) { %>
        <h1 style="text-align: center;">Portail Employé - Connexion</h1>
        <div class="card" style="max-width: 400px; margin: 0 auto;">
            <% if (loginError != null) { %>
                <p style="color: red; text-align: center;"><%= loginError %></p>
            <% } %>
            <form method="POST">
                <label>Hôtel :</label>
                <select name="hotel_id" required style="width: 100%;">
                    <option value="">-- Sélectionnez --</option>
                    <option value="1">Québec (Frontenac)</option>
                    <option value="2">Montréal (Westin)</option>
                    <option value="3">Montréal (Bonaventure)</option>
                    <option value="4">Toronto (Ritz)</option>
                    <option value="5">Vancouver (Sheraton)</option>
                    <option value="6">Banff (Springs)</option>
                    <option value="7">Ottawa (Marriott)</option>
                    <option value="8">Ottawa (Alt)</option>
                </select><br><br>
                <label>Mot de passe :</label>
                <input type="password" name="password" required style="width: 100%;"><br><br>
                <button type="submit" style="width: 100%;">Se Connecter</button>
            </form>
            <div style="text-align: center; margin-top: 15px;">
                <a href="index.html" style="color: #007BFF; text-decoration: none; font-weight: bold;">← Retour à l'accueil</a>
            </div>
        </div>
    <% } else { %>

        <div class="header-top">
            <h1>Hôtel #<%= loggedHotel %> - Gestion</h1>
            <div>
                <a href="index.html" style="background: #6c757d; color: white; padding: 8px 12px; text-decoration: none; border-radius: 4px; margin-right: 10px;">🏠 Accueil Site</a>
                <a href="employe.jsp?logout=true" style="background: #dc3545; color: white; padding: 8px 12px; text-decoration: none; border-radius: 4px;">Déconnexion</a>
            </div>
        </div>

        <%
            Connection conn = null;
            try {
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "radan066");

                // --- LOGIQUE ANNULATION (AVEC ARCHIVAGE) ---
                if (request.getParameter("cancel_id") != null) {
                    int cancelId = Integer.parseInt(request.getParameter("cancel_id"));
                    
                    // 1. Archiver comme 'ANNULÉ'
                    conn.createStatement().executeUpdate(
                        "INSERT INTO reservation_archive (reservation_id, customer_sin, hotel_room_id, status, start_date, end_date) " +
                        "SELECT reservation_id, customer_id, CAST(room_number AS INTEGER), 'ANNULÉ', start_date, end_date FROM reservation WHERE reservation_id = " + cancelId
                    );
                    // 2. Supprimer la réservation
                    conn.createStatement().executeUpdate("DELETE FROM reservation WHERE reservation_id = " + cancelId);
                    out.println("<p style='color:red;'>✅ Réservation annulée et archivée.</p>");
                }

                // --- LOGIQUE CHECK-IN (TABLEAU) (AVEC ARCHIVAGE) ---
                if (request.getParameter("checkin_id") != null && request.getParameter("responsable_id") != null) {
                    int checkinId = Integer.parseInt(request.getParameter("checkin_id"));
                    
                    // 1. Mettre à jour la réservation
                    PreparedStatement psUp = conn.prepareStatement("UPDATE reservation SET statut = 'OCCUPÉ', checkin_employee_id = ? WHERE reservation_id = ?");
                    psUp.setInt(1, Integer.parseInt(request.getParameter("responsable_id")));
                    psUp.setInt(2, checkinId);
                    psUp.executeUpdate();
                    
                    // 2. Archiver comme 'OCCUPÉ'
                    conn.createStatement().executeUpdate(
                        "INSERT INTO reservation_archive (reservation_id, customer_sin, hotel_room_id, status, start_date, end_date) " +
                        "SELECT reservation_id, customer_id, CAST(room_number AS INTEGER), 'OCCUPÉ', start_date, end_date FROM reservation WHERE reservation_id = " + checkinId
                    );
                    out.println("<p style='color:green; font-weight:bold;'>✅ Check-in validé et archivé !</p>");
                }

                // --- LOGIQUE WALK-IN MANUEL (DÉPART SEULEMENT, ARRIVÉE = AUJOURD'HUI) ---
                if ("walkin".equals(request.getParameter("action"))) {
                    String roomNum = request.getParameter("room_number");
                    String dateFin = request.getParameter("date_depart");
                    
                    // On vérifie le conflit à partir de la date d'aujourd'hui (CURRENT_DATE)
                    PreparedStatement psConf = conn.prepareStatement(
                        "SELECT COUNT(*) FROM reservation WHERE room_number = ? AND hotel_number = ? " +
                        "AND (start_date < ?::date AND end_date > CURRENT_DATE)");
                    psConf.setString(1, roomNum);
                    psConf.setInt(2, loggedHotel);
                    psConf.setString(3, dateFin);
                    ResultSet rsConf = psConf.executeQuery();
                    rsConf.next();
                    
                    if (rsConf.getInt(1) > 0) {
                        out.println("<p style='color:orange; font-weight:bold;'>⚠️ Conflit : Cette chambre est déjà réservée pendant ces dates !</p>");
                    } else {
                        // Création Client
                        PreparedStatement psC = conn.prepareStatement("INSERT INTO customer (full_name, address, id_type) VALUES (?, ?, ?) RETURNING customer_id");
                        psC.setString(1, request.getParameter("nom"));
                        psC.setString(2, request.getParameter("adresse"));
                        psC.setString(3, request.getParameter("piece_id"));
                        ResultSet rsC = psC.executeQuery();
                        if (rsC.next()) {
                            int newCustId = rsC.getInt("customer_id");
                            
                            // 1. Création Réservation (avec RETURNING reservation_id)
                            PreparedStatement psR = conn.prepareStatement(
                                "INSERT INTO reservation (room_number, hotel_number, start_date, end_date, customer_id, statut, checkin_employee_id) VALUES (?, ?, CURRENT_DATE, ?::date, ?, 'OCCUPÉ', ?) RETURNING reservation_id");
                            psR.setString(1, roomNum);
                            psR.setInt(2, loggedHotel);
                            psR.setString(3, dateFin);
                            psR.setInt(4, newCustId);
                            psR.setInt(5, Integer.parseInt(request.getParameter("responsable_id")));
                            ResultSet rsNewRes = psR.executeQuery();
                            
                            if (rsNewRes.next()) {
                                int newResId = rsNewRes.getInt("reservation_id");
                                
                                // 2. Archivage
                                PreparedStatement psArc = conn.prepareStatement(
                                    "INSERT INTO reservation_archive (reservation_id, customer_sin, hotel_room_id, status, start_date, end_date) " +
                                    "VALUES (?, ?, ?, 'OCCUPÉ', CURRENT_DATE, ?::date)"
                                );
                                psArc.setInt(1, newResId);
                                psArc.setInt(2, newCustId);
                                psArc.setInt(3, Integer.parseInt(roomNum));
                                psArc.setString(4, dateFin);
                                psArc.executeUpdate();

                                out.println("<p style='color:green; font-weight:bold;'>✅ Check-in manuel réussi et archivé !</p>");
                            }
                        }
                    }
                }
        %>

        <div class="card">
            <h2>Réservations de votre hôtel</h2>
            <table>
                <tr>
                    <th>ID</th><th>Statut</th><th>Client</th><th>Chambre</th><th>Arrivée</th><th>Départ</th><th>Action</th>
                </tr>
                <%
                    String sqlFusion = "SELECT r.reservation_id, r.customer_id, c.full_name, r.room_number, r.start_date, r.end_date, r.statut, e.full_name as emp_name " +
                                       "FROM reservation r INNER JOIN customer c ON r.customer_id = c.customer_id " +
                                       "LEFT JOIN employee e ON r.checkin_employee_id = e.employee_id " +
                                       "WHERE r.hotel_number = " + loggedHotel + " ORDER BY r.reservation_id DESC";
                    ResultSet rsTable = conn.createStatement().executeQuery(sqlFusion);
                    while(rsTable.next()) {
                        String s = rsTable.getString("statut");
                %>
                <tr>
                    <td>#<%= rsTable.getInt("reservation_id") %></td>
                    <td><span class="<%= "EN ATTENTE".equals(s) ? "badge-attente" : "badge-occupe" %>"><%= s %></span></td>
                    <td><%= rsTable.getString("full_name") %></td>
                    <td><%= rsTable.getString("room_number") %></td>
                    <td><%= rsTable.getDate("start_date") %></td>
                    <td><%= rsTable.getDate("end_date") %></td>
                    <td>
                        <% if ("EN ATTENTE".equals(s)) { %>
                            <form method="POST" style="display:inline;">
                                <input type="hidden" name="checkin_id" value="<%= rsTable.getInt("reservation_id") %>">
                                <select name="responsable_id" required>
                                    <option value="">Employé...</option>
                                    <% 
                                        ResultSet rsE = conn.createStatement().executeQuery("SELECT employee_id, full_name, role FROM employee WHERE hotel_number = " + loggedHotel + " AND role IN ('Réceptionniste', 'Gérant')");
                                        while(rsE.next()) { out.println("<option value='"+rsE.getInt(1)+"'>"+rsE.getString(2)+" ("+rsE.getString(3)+")</option>"); }
                                    %>
                                </select>
                                <button type="submit" class="btn-checkin">Check-in</button>
                            </form>
                        <% } %>
                        <a href="employe.jsp?cancel_id=<%= rsTable.getInt("reservation_id") %>" class="btn-annuler">Annuler</a>
                    </td>
                </tr>
                <% } %>
            </table>
        </div>

        <div class="card">
            <h2>Check-in Manuel (Walk-in)</h2>
            <form method="POST">
                <input type="hidden" name="action" value="walkin">
                
                <div class="form-row" style="grid-template-columns: 1fr 1fr 1fr;">
                    <div class="input-group">
                        <label>Nom du Client</label>
                        <input type="text" name="nom" required style="width: 100%;">
                    </div>
                    <div class="input-group">
                        <label>Adresse</label>
                        <input type="text" name="adresse" required style="width: 100%;">
                    </div>
                    <div class="input-group">
                        <label>Pièce d'identité</label>
                        <select name="piece_id" style="width: 100%;">
                            <option value="NAS">NAS</option>
                            <option value="Passeport">Passeport</option>
                            <option value="Permis de conduire">Permis de conduire</option>
                        </select>
                    </div>
                </div>

                <div class="form-row" style="grid-template-columns: 1fr 1fr 1fr;">
                    <div class="input-group">
                        <label>Chambre</label>
                        <select name="room_number" required style="width: 100%;">
                            <option value="">-- Choisir --</option>
                            <%
                                ResultSet rsR = conn.createStatement().executeQuery("SELECT room_number FROM hotel_room WHERE hotel_number = " + loggedHotel);
                                while(rsR.next()){ out.println("<option value='"+rsR.getString(1)+"'>Chambre "+rsR.getString(1)+"</option>"); }
                            %>
                        </select>
                    </div>
                    
                    <div class="input-group">
                        <label>Date de départ</label>
                        <input type="date" name="date_depart" id="walkin_depart" required style="width: 100%;">
                    </div>
                    
                    <div class="input-group">
                        <label>Employé Responsable</label>
                        <select name="responsable_id" required style="width: 100%;">
                            <option value="">-- Qui êtes-vous ? --</option>
                            <%
                                ResultSet rsE2 = conn.createStatement().executeQuery("SELECT employee_id, full_name FROM employee WHERE hotel_number = " + loggedHotel + " AND role IN ('Réceptionniste', 'Gérant')");
                                while(rsE2.next()){ out.println("<option value='"+rsE2.getInt(1)+"'>"+rsE2.getString(2)+"</option>"); }
                            %>
                        </select>
                    </div>
                </div>

                <button type="submit" style="background-color: #007BFF; width: 100%; margin-top: 10px; padding: 10px;">Valider le Check-in (Aujourd'hui)</button>
            </form>
        </div>

        <% 
            } catch(Exception e) { out.println("Erreur : " + e.getMessage()); } 
            finally { if (conn != null) conn.close(); }
        %>
    <% } %>

    <script>
        const walkinDepartInput = document.getElementById('walkin_depart');
        if (walkinDepartInput) {
            let tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            walkinDepartInput.min = tomorrow.toISOString().split('T')[0];
        }
    </script>
</body>
</html>