/***************************************************
*
* cismet GmbH, Saarbruecken, Germany
*
*              ... and it just works.
*
****************************************************/
package de.cismet.custom.wrrl.reportgenerator;

import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

import org.eclipse.birt.core.exception.BirtException;
import org.eclipse.birt.core.framework.Platform;
import org.eclipse.birt.report.engine.api.EngineConfig;
import org.eclipse.birt.report.engine.api.EngineException;
import org.eclipse.birt.report.engine.api.HTMLRenderOption;
import org.eclipse.birt.report.engine.api.IRenderOption;
import org.eclipse.birt.report.engine.api.IReportEngine;
import org.eclipse.birt.report.engine.api.IReportEngineFactory;
import org.eclipse.birt.report.engine.api.IReportRunnable;
import org.eclipse.birt.report.engine.api.IRunAndRenderTask;
import org.eclipse.birt.report.engine.api.RenderOption;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

/**
 * Hello world!
 *
 * @version  $Revision$, $Date$
 */
public class GenerateReport {

    //~ Static fields/initializers ---------------------------------------------

    private static final Logger LOG = Logger.getLogger(GenerateReport.class);

    private static final String PROPERTY_GENERATE_TARGETDIRECTORY = "generate.targetDirectory";
    private static final String PROPERTY_JDBC_DRIVER = "jdbc.driver";
    private static final String PROPERTY_JDBC_URL = "jdbc.url";
    private static final String PROPERTY_JDBC_USER = "jdbc.user";
    private static final String PROPERTY_JDBC_PASSWORD = "jdbc.password";
    private static final String PROPERTY_REPORTFILTER_PREFIX_LEVEL1 = "reportfilter.prefix.level1";
    private static final String PROPERTY_REPORTFILTER_PREFIX_LEVEL2 = "reportfilter.prefix.level2";
    private static final String PROPERTY_REPORTFILTER_PREFIX_LEVEL3 = "reportfilter.prefix.level3";
    private static final String PROPERTY_REPORTFILTER_PREFIX_LEVEL4 = "reportfilter.prefix.level4";
    private static final String PROPERTY_REPORTFILTER_PREFIX_LUNG = "reportfilter.prefix.lung";
    private static final String PROPERTY_REPORTFILTER_SUFFIX_REPORT = "reportfilter.suffix.report";
    private static final String PROPERTY_REPORTFILTER_SUFFIX_TARGET = "reportfilter.suffix.target";
    private static final String PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2 = "reportfilter.replacementToken.level2";
    private static final String PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2_LUNG =
        "reportfilter.replacementToken.level2.lung";
    private static final String PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3 = "reportfilter.replacementToken.level3";
    private static final String PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3_LUNG =
        "reportfilter.replacementToken.level3.lung";
    private static final String PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL4 = "reportfilter.replacementToken.level4";

    private static final String CONFIG_BATCHREPORT = "reportgenerator.properties";
    private static final String CONFIG_LOGGING = "log4j.properties";

    private static String basePath;

    //~ Instance fields --------------------------------------------------------

    private IReportEngine engine;
    private IRenderOption options;
    private Properties properties;

    //~ Constructors -----------------------------------------------------------

    /**
     * Creates a new BatchReport object.
     */
    public GenerateReport() {
        initializeProperties();
        initializeEngine();

        options = new RenderOption();
        options.setOutputFormat("html");

        final HTMLRenderOption htmlOptions = new HTMLRenderOption(options);
        htmlOptions.setEmbeddable(false);
        htmlOptions.setEnableInlineStyle(false);
        htmlOptions.setUrlEncoding("UTF-8");
    }

    //~ Methods ----------------------------------------------------------------

    /**
     * DOCUMENT ME!
     */
    private static void initializeLogging() {
        final File configFile = new File(basePath, CONFIG_LOGGING);
        if (!configFile.canRead() || !configFile.isFile()) {
            BasicConfigurator.configure();
        } else {
            PropertyConfigurator.configure(configFile.getAbsolutePath());
        }
    }

    /**
     * DOCUMENT ME!
     */
    private void initializeProperties() {
        properties = new Properties();

        Reader reader = null;

        try {
            reader = new FileReader(new File(basePath, CONFIG_BATCHREPORT));
            properties.load(reader);
        } catch (FileNotFoundException ex) {
            LOG.error("Couldn't find configuration file '" + CONFIG_BATCHREPORT + "'.", ex);
        } catch (IOException ex) {
            LOG.error("Error while reading configuration file '" + CONFIG_BATCHREPORT + "'.", ex);
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException ex) {
                LOG.warn("Couldn't close configuration file '" + CONFIG_BATCHREPORT + "'.", ex);
            }
        }

        if (!properties.containsKey(PROPERTY_GENERATE_TARGETDIRECTORY)) {
            LOG.warn("No target directory specified. Please add an entry '" + PROPERTY_GENERATE_TARGETDIRECTORY
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'html' as target directory.");
            properties.setProperty(PROPERTY_GENERATE_TARGETDIRECTORY, "html");
        }
        if (!properties.containsKey(PROPERTY_JDBC_DRIVER)) {
            LOG.warn("No JDBC driver specified. Please add an entry '" + PROPERTY_JDBC_URL + "' in ' "
                        + CONFIG_BATCHREPORT
                        + "'. Trying 'org.postgresql.Driver' now.");
            properties.setProperty(PROPERTY_JDBC_DRIVER, "org.postgresql.Driver");
        }
        if (!properties.containsKey(PROPERTY_JDBC_URL)) {
            LOG.warn("No JDBC url specified. Please add an entry '" + PROPERTY_JDBC_URL + "' in ' " + CONFIG_BATCHREPORT
                        + "'.");
        }
        if (!properties.containsKey(PROPERTY_JDBC_USER)) {
            LOG.warn("No JDBC user specified. Please add an entry '" + PROPERTY_JDBC_USER + "' in ' "
                        + CONFIG_BATCHREPORT + "'.");
        }
        if (!properties.containsKey(PROPERTY_JDBC_PASSWORD)) {
            LOG.warn("No JDBC password specified. Please add an entry '" + PROPERTY_JDBC_PASSWORD + "' in ' "
                        + CONFIG_BATCHREPORT + "'.");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_PREFIX_LEVEL1)) {
            LOG.warn("No prefix for level 1 reports specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_PREFIX_LEVEL1
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using '01_mv' as prefix for level 1 reports.");
            properties.setProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL1, "01_mv");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_PREFIX_LEVEL2)) {
            LOG.warn("No prefix for level 2 reports specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_PREFIX_LEVEL2
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using '02' as prefix for level 2 reports.");
            properties.setProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL2, "02");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_PREFIX_LEVEL3)) {
            LOG.warn("No prefix for level 3 reports specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_PREFIX_LEVEL3
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using '03' as prefix for level 3 reports.");
            properties.setProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL3, "03");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_PREFIX_LEVEL4)) {
            LOG.warn("No prefix for level 4 reports specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_PREFIX_LEVEL4
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using '04' as prefix for level 4 reports.");
            properties.setProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL4, "04");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_PREFIX_LUNG)) {
            LOG.warn("No prefix for lung specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_PREFIX_LUNG
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'lung' as prefix for lung.");
            properties.setProperty(PROPERTY_REPORTFILTER_PREFIX_LUNG, "lung");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_SUFFIX_REPORT)) {
            LOG.warn("No suffix for reports specified. Please add an entry '" + PROPERTY_REPORTFILTER_SUFFIX_REPORT
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using '.rptdesign' as suffix for reports.");
            properties.setProperty(PROPERTY_REPORTFILTER_SUFFIX_REPORT, ".rptdesign");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_SUFFIX_TARGET)) {
            LOG.warn("No suffix for target files specified. Please add an entry '" + PROPERTY_REPORTFILTER_SUFFIX_TARGET
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using '.html' as suffix for target files.");
            properties.setProperty(PROPERTY_REPORTFILTER_SUFFIX_TARGET, ".html");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2)) {
            LOG.warn("No replacement token for level 2 specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'stalu' as replacement token for level 2.");
            properties.setProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2, "stalu");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2_LUNG)) {
            LOG.warn("No replacement token for level 2 (lung) specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2_LUNG
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'fge' as replacement token for level 2 (lung).");
            properties.setProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2_LUNG, "fge");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3)) {
            LOG.warn("No replacement token for level 3 specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'fge' as replacement token for level 3.");
            properties.setProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3, "fge");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3_LUNG)) {
            LOG.warn("No replacement token for level 3 (lung) specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3_LUNG
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'bg' as replacement token for level 3 (lung).");
            properties.setProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3_LUNG, "bg");
        }
        if (!properties.containsKey(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL4)) {
            LOG.warn("No replacement token for level 4 specified. Please add an entry '"
                        + PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL4
                        + "' in ' " + CONFIG_BATCHREPORT + "'.");
            LOG.info("Using 'bg' as replacement token for level 4.");
            properties.setProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL4, "bg");
        }
    }

    /**
     * DOCUMENT ME!
     */
    private void initializeEngine() {
        final EngineConfig config = new EngineConfig();
        config.setLogFile("birt.log");

        try {
            Platform.startup(config);
        } catch (BirtException e) {
            LOG.error("Couldn't start platform.", e);
            System.exit(0);
        }

        final IReportEngineFactory factory = (IReportEngineFactory)Platform.createFactoryObject(
                IReportEngineFactory.EXTENSION_REPORT_ENGINE_FACTORY);
        engine = factory.createReportEngine(config);
    }

    /**
     * DOCUMENT ME!
     */
    private void shutdownEngine() {
        engine.destroy();
        Platform.shutdown();
    }

    /**
     * DOCUMENT ME!
     */
    public void generateReports() {
        final WRRLStructureProvider structureProvider = WRRLStructureProvider.getWRRLStructureProvider(
                properties.getProperty(PROPERTY_JDBC_DRIVER),
                properties.getProperty(PROPERTY_JDBC_URL),
                properties.getProperty(PROPERTY_JDBC_USER),
                properties.getProperty(PROPERTY_JDBC_PASSWORD));

        if (structureProvider == null) {
            LOG.error("Couldn't connect to the WRRL database");
            return;
        }

        final WRRLReportProvider reportProvider;
        try {
            reportProvider = WRRLReportProvider.getWRRLReportProvider(
                    properties.getProperty(PROPERTY_GENERATE_TARGETDIRECTORY),
                    properties.getProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL1),
                    properties.getProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL2),
                    properties.getProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL3),
                    properties.getProperty(PROPERTY_REPORTFILTER_PREFIX_LEVEL4),
                    properties.getProperty(PROPERTY_REPORTFILTER_PREFIX_LUNG),
                    properties.getProperty(PROPERTY_REPORTFILTER_SUFFIX_REPORT),
                    properties.getProperty(PROPERTY_REPORTFILTER_SUFFIX_TARGET),
                    properties.getProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2),
                    properties.getProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL2_LUNG),
                    properties.getProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3),
                    properties.getProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL3_LUNG),
                    properties.getProperty(PROPERTY_REPORTFILTER_REPLACEMENTTOKEN_LEVEL4));
        } catch (Exception ex) {
            LOG.error(
                "Could not instantiate the provider for WRRL reports. Please check if source and target directory are valid.",
                ex);
            return;
        }

        final Map<String, String> parameters = new HashMap<String, String>();
        parameters.put("jdbc_driver", properties.getProperty(PROPERTY_JDBC_DRIVER));
        parameters.put("jdbc_url", properties.getProperty(PROPERTY_JDBC_URL));
        parameters.put("jdbc_user", properties.getProperty(PROPERTY_JDBC_USER));
        parameters.put("jdbc_password", properties.getProperty(PROPERTY_JDBC_PASSWORD));

        for (final Map.Entry<String, String> entry : reportProvider.getReportsLevel1().entrySet()) {
            generateReport(entry.getKey(), entry.getValue(), parameters);
        }

        for (final String stalu : structureProvider.getLevel2()) {
            parameters.put("stalu", stalu);

            for (final Map.Entry<String, String> entry : reportProvider.getReportsLevel2(parameters).entrySet()) {
                generateReport(entry.getKey(), entry.getValue(), parameters);
            }

            parameters.remove("stalu");
        }

        for (final String fge : structureProvider.getLevel2Lung()) {
            parameters.put("fge", fge);

            for (final Map.Entry<String, String> entry : reportProvider.getReportsLevel2Lung(parameters).entrySet()) {
                generateReport(entry.getKey(), entry.getValue(), parameters);
            }

            parameters.remove("fge");
        }

        for (final String[] stalu_fge : structureProvider.getLevel3()) {
            parameters.put("stalu", stalu_fge[0]);
            parameters.put("fge", stalu_fge[1]);

            for (final Map.Entry<String, String> entry : reportProvider.getReportsLevel3(parameters).entrySet()) {
                generateReport(entry.getKey(), entry.getValue(), parameters);
            }

            parameters.remove("stalu");
            parameters.remove("fge");
        }

        for (final String[] fge_bg : structureProvider.getLevel3Lung()) {
            parameters.put("fge", fge_bg[0]);
            parameters.put("bg", fge_bg[1]);

            for (final Map.Entry<String, String> entry : reportProvider.getReportsLevel3Lung(parameters).entrySet()) {
                generateReport(entry.getKey(), entry.getValue(), parameters);
            }

            parameters.remove("fge");
            parameters.remove("bg");
        }

        for (final String[] stalu_fge_bg : structureProvider.getLevel4()) {
            parameters.put("stalu", stalu_fge_bg[0]);
            parameters.put("fge", stalu_fge_bg[1]);
            parameters.put("bg", stalu_fge_bg[2]);

            for (final Map.Entry<String, String> entry : reportProvider.getReportsLevel4(parameters).entrySet()) {
                generateReport(entry.getKey(), entry.getValue(), parameters);
            }

            parameters.remove("stalu");
            parameters.remove("fge");
            parameters.remove("bg");
        }
    }

    /**
     * DOCUMENT ME!
     *
     * @param  source      DOCUMENT ME!
     * @param  target      DOCUMENT ME!
     * @param  parameters  DOCUMENT ME!
     */
    public void generateReport(final String source, final String target, final Map<String, String> parameters) {
        try {
            final IReportRunnable runnable = engine.openReportDesign(source);
            final IRunAndRenderTask task = engine.createRunAndRenderTask(runnable);

            options.setOutputFileName(
                properties.getProperty(PROPERTY_GENERATE_TARGETDIRECTORY)
                        + File.separator
                        + target);

            task.setParameterValues(parameters);
            task.setRenderOption(options);
            task.setLocale(Locale.GERMAN);

            task.run();
        } catch (EngineException e) {
            LOG.warn("Couldn't generate report '" + target + "'.", e);
        }
    }

    /**
     * DOCUMENT ME!
     *
     * @param  args  DOCUMENT ME!
     */
    public static void main(final String[] args) {
        if ((args != null) && (args.length > 0)) {
            final File basePathFile = new File(args[0]);
            if (!basePathFile.exists()) {
                basePath = System.getProperty("user.dir");
            } else {
                basePath = args[0];
            }
        }

        initializeLogging();

        final GenerateReport batchReport = new GenerateReport();
        batchReport.generateReports();
        batchReport.shutdownEngine();
    }
}
