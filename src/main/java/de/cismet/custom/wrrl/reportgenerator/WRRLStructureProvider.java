/***************************************************
*
* cismet GmbH, Saarbruecken, Germany
*
*              ... and it just works.
*
****************************************************/
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package de.cismet.custom.wrrl.reportgenerator;

import org.apache.log4j.Logger;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import java.util.ArrayList;
import java.util.List;

/**
 * DOCUMENT ME!
 *
 * @author   jweintraut
 * @version  $Revision$, $Date$
 */
public class WRRLStructureProvider {

    //~ Static fields/initializers ---------------------------------------------

    private static final Logger LOG = Logger.getLogger(WRRLStructureProvider.class);

    private static final String QUERY_LEVEL2 = "SELECT DISTINCT lower(stalu) as stalu FROM statistics_dimensions";
    private static final String QUERY_LEVEL3 =
        "SELECT DISTINCT lower(stalu) as stalu, lower(fge) as fge FROM statistics_dimensions WHERE fge IS NOT NULL";
    private static final String QUERY_LEVEL4 =
        "SELECT DISTINCT lower(stalu) as stalu, lower(fge) as fge, lower(bg) as bg FROM statistics_dimensions WHERE fge IS NOT NULL AND bg IS NOT NULL";

    //~ Instance fields --------------------------------------------------------

    private Connection connection;

    //~ Constructors -----------------------------------------------------------

    /**
     * Creates a new WRRLStructureProvider object.
     *
     * @param  connection  DOCUMENT ME!
     */
    private WRRLStructureProvider(final Connection connection) {
        this.connection = connection;
    }

    //~ Methods ----------------------------------------------------------------

    /**
     * DOCUMENT ME!
     *
     * @param   url   DOCUMENT ME!
     * @param   user  DOCUMENT ME!
     * @param   pass  DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public static WRRLStructureProvider getWRRLStructureProvider(final String url,
            final String user,
            final String pass) {
        WRRLStructureProvider result = null;

        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException ex) {
            LOG.error("PostgreSQL driver couldn't be loaded.", ex);
            return result;
        }

        Connection connection = null;

        try {
            connection = DriverManager.getConnection(url, user, pass);
        } catch (SQLException ex) {
            LOG.error("Couldn't establish the JDBC connection.", ex);
            return result;
        }

        result = new WRRLStructureProvider(connection);
        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String> getLevel2() {
        List<String> result = new ArrayList<String>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_LEVEL2);

            while (resultSet.next()) {
                result.add(resultSet.getString("stalu"));
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading level 2 of WRRL structure", ex);
            result = new ArrayList<String>();
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getLevel3() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_LEVEL3);

            while (resultSet.next()) {
                final String[] entry = new String[2];
                entry[0] = resultSet.getString("stalu");
                entry[1] = resultSet.getString("fge");
                result.add(entry);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading level 3 of WRRL structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getLevel4() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_LEVEL4);

            while (resultSet.next()) {
                final String[] entry = new String[3];
                entry[0] = resultSet.getString("stalu");
                entry[1] = resultSet.getString("fge");
                entry[2] = resultSet.getString("bg");
                result.add(entry);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading level 4 of WRRL structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }
}
