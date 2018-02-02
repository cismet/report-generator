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
public class ProjectStructureProvider {

    //~ Static fields/initializers ---------------------------------------------

    private static final Logger LOG = Logger.getLogger(ProjectStructureProvider.class);

    private static final String QUERY_STALU = "SELECT DISTINCT id, name FROM ogc.stalu_10_baum";
    private static final String QUERY_STALU_FGE =
        "SELECT DISTINCT s.id, s.name, f.nr, f.name FROM ogc.stalu_10_baum s, flussgebietseinheit f join geom fg on f.geom = fg.id where st_intersects(s.the_geom, fg.geo_field)";
    // The second intersects function must be _st_intersects (start with underscore). Otherwise, the query will use
    // too much memory
    private static final String QUERY_STALU_FGE_PE =
        "SELECT DISTINCT s.id, s.name, f.nr, f.name, p.kuerzel, p.name FROM ogc.stalu_10_baum s, flussgebietseinheit f join geom fg on f.geom = fg.id, planungseinheit p join geom pg on p.geom = pg.id where st_intersects(s.the_geom, fg.geo_field) and _st_intersects(fg.geo_field, pg.geo_field)";
    private static final String QUERY_FGE = "SELECT DISTINCT lower(nr) as fge, name FROM flussgebietseinheit";
    private static final String QUERY_FGE_PE =
        "SELECT DISTINCT lower(f.nr), f.name, lower(p.kuerzel), p.name FROM flussgebietseinheit f join geom fg on f.geom = fg.id, planungseinheit p join geom pg on p.geom = pg.id where st_intersects(fg.geo_field, pg.geo_field)";

    //~ Instance fields --------------------------------------------------------

    private Connection connection;

    //~ Constructors -----------------------------------------------------------

    /**
     * Creates a new WRRLStructureProvider object.
     *
     * @param  connection  DOCUMENT ME!
     */
    private ProjectStructureProvider(final Connection connection) {
        this.connection = connection;
    }

    //~ Methods ----------------------------------------------------------------

    /**
     * DOCUMENT ME!
     *
     * @param   driver  DOCUMENT ME!
     * @param   url     DOCUMENT ME!
     * @param   user    DOCUMENT ME!
     * @param   pass    DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public static ProjectStructureProvider getProjectStructureProvider(final String driver,
            final String url,
            final String user,
            final String pass) {
        ProjectStructureProvider result = null;

        try {
            Class.forName(driver);
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

        result = new ProjectStructureProvider(connection);
        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getStalu() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_STALU);

            while (resultSet.next()) {
                final String[] tmp = new String[2];
                tmp[0] = resultSet.getString(1);
                tmp[1] = resultSet.getString(2);
                result.add(tmp);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading fge of project structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getStaluFge() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_STALU_FGE);

            while (resultSet.next()) {
                final String[] tmp = new String[4];
                tmp[0] = resultSet.getString(1);
                tmp[1] = resultSet.getString(2);
                tmp[2] = resultSet.getString(3);
                tmp[3] = resultSet.getString(4);
                result.add(tmp);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading fge of project structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getStaluFgePe() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_STALU_FGE_PE);

            while (resultSet.next()) {
                final String[] tmp = new String[6];
                tmp[0] = resultSet.getString(1);
                tmp[1] = resultSet.getString(2);
                tmp[2] = resultSet.getString(3);
                tmp[3] = resultSet.getString(4);
                tmp[4] = resultSet.getString(5);
                tmp[5] = resultSet.getString(6);
                result.add(tmp);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading fge of project structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getFge() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_FGE);

            while (resultSet.next()) {
                final String[] tmp = new String[2];
                tmp[0] = resultSet.getString("fge");
                tmp[1] = resultSet.getString("name");
                result.add(tmp);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading fge of project structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public List<String[]> getFgePe() {
        List<String[]> result = new ArrayList<String[]>();

        try {
            final Statement statement = connection.createStatement();
            final ResultSet resultSet = statement.executeQuery(QUERY_FGE_PE);

            while (resultSet.next()) {
                final String[] tmp = new String[4];
                tmp[0] = resultSet.getString(1);
                tmp[1] = resultSet.getString(2);
                tmp[2] = resultSet.getString(3);
                tmp[3] = resultSet.getString(4);

                result.add(tmp);
            }
        } catch (SQLException ex) {
            LOG.error("Error while reading fge of project structure", ex);
            result = new ArrayList<String[]>();
        }

        return result;
    }
}
