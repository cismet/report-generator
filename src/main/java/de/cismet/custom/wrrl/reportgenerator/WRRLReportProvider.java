/***************************************************
*
* cismet GmbH, Saarbruecken, Germany
*
*              ... and it just works.
*
****************************************************/
/*
 *  Copyright (C) 2011 jweintraut
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package de.cismet.custom.wrrl.reportgenerator;

import org.apache.log4j.Logger;

import java.io.File;
import java.io.FilenameFilter;

import java.util.HashMap;
import java.util.Map;

/**
 * DOCUMENT ME!
 *
 * @author   jweintraut
 * @version  $Revision$, $Date$
 */
public class WRRLReportProvider {

    //~ Static fields/initializers ---------------------------------------------

    private static final Logger LOG = Logger.getLogger(WRRLReportProvider.class);

    //~ Instance fields --------------------------------------------------------

    private String suffixReport;
    private String suffixTarget;

    private FilenameFilter filterLevel1;
    private FilenameFilter filterLevel2;
    private FilenameFilter filterLevel3;
    private FilenameFilter filterLevel4;

    private File sourceDirectory;
    private File targetDirectory;

    //~ Constructors -----------------------------------------------------------

    /**
     * Creates a new WRRLReportProvider object.
     *
     * @param  prefixLevel1            DOCUMENT ME!
     * @param  prefixLevel2            DOCUMENT ME!
     * @param  prefixLevel3            DOCUMENT ME!
     * @param  prefixLevel4            DOCUMENT ME!
     * @param  suffixReport            DOCUMENT ME!
     * @param  suffixTarget            DOCUMENT ME!
     * @param  replacementTokenLevel2  DOCUMENT ME!
     * @param  replacementTokenLevel3  DOCUMENT ME!
     * @param  replacementTokenLevel4  DOCUMENT ME!
     */
    private WRRLReportProvider(final String prefixLevel1,
            final String prefixLevel2,
            final String prefixLevel3,
            final String prefixLevel4,
            final String suffixReport,
            final String suffixTarget,
            final String replacementTokenLevel2,
            final String replacementTokenLevel3,
            final String replacementTokenLevel4) {
        filterLevel1 = new WRRLReportFilter(prefixLevel1, suffixReport);
        filterLevel2 = new WRRLReportFilter(prefixLevel2.concat("_").concat(replacementTokenLevel2), suffixReport);
        filterLevel3 = new WRRLReportFilter(prefixLevel3.concat("_").concat(replacementTokenLevel2).concat("_").concat(
                    replacementTokenLevel3),
                suffixReport);
        filterLevel4 = new WRRLReportFilter(prefixLevel4.concat("_").concat(replacementTokenLevel2).concat("_").concat(
                    replacementTokenLevel3).concat("_").concat(replacementTokenLevel4),
                suffixReport);

        this.suffixReport = suffixReport;
        this.suffixTarget = suffixTarget;
    }

    //~ Methods ----------------------------------------------------------------

    /**
     * DOCUMENT ME!
     *
     * @param   sourceDirectory         DOCUMENT ME!
     * @param   targetDirectory         DOCUMENT ME!
     * @param   prefixLevel1            DOCUMENT ME!
     * @param   prefixLevel2            DOCUMENT ME!
     * @param   prefixLevel3            DOCUMENT ME!
     * @param   prefixLevel4            DOCUMENT ME!
     * @param   suffixReport            DOCUMENT ME!
     * @param   suffixTarget            DOCUMENT ME!
     * @param   replacementTokenLevel2  DOCUMENT ME!
     * @param   replacementTokenLevel3  DOCUMENT ME!
     * @param   replacementTokenLevel4  DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     *
     * @throws  Exception  DOCUMENT ME!
     */
    public static WRRLReportProvider getWRRLReportProvider(final String sourceDirectory,
            final String targetDirectory,
            final String prefixLevel1,
            final String prefixLevel2,
            final String prefixLevel3,
            final String prefixLevel4,
            final String suffixReport,
            final String suffixTarget,
            final String replacementTokenLevel2,
            final String replacementTokenLevel3,
            final String replacementTokenLevel4) throws Exception {
        final File source = new File(sourceDirectory);
        final File target = new File(targetDirectory);

        try {
            validateAndPrepareDirectories(source, target);
        } catch (Exception e) {
            throw e;
        }

        final WRRLReportProvider result = new WRRLReportProvider(
                prefixLevel1,
                prefixLevel2,
                prefixLevel3,
                prefixLevel4,
                suffixReport,
                suffixTarget,
                replacementTokenLevel2,
                replacementTokenLevel3,
                replacementTokenLevel4);

        result.sourceDirectory = source;
        result.targetDirectory = target;

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @param   sourceDirectory  DOCUMENT ME!
     * @param   targetDirectory  DOCUMENT ME!
     *
     * @throws  IllegalArgumentException  DOCUMENT ME!
     */
    protected static void validateAndPrepareDirectories(final File sourceDirectory, final File targetDirectory) {
        if (!sourceDirectory.canRead() || !sourceDirectory.isDirectory()) {
            LOG.error(
                "The source directory given for generation of reports doesn't exist or isn't a directory or can't be read.");
            throw new IllegalArgumentException("Source directory invalid.");
        }

        targetDirectory.mkdirs();

        if (!targetDirectory.canWrite() || !targetDirectory.isDirectory()) {
            LOG.error("The target directory given for generation of reports isn't a directory or isn't writable.");
            throw new IllegalArgumentException("Target directory invalid.");
        }
    }

    /**
     * DOCUMENT ME!
     *
     * @param   filter        DOCUMENT ME!
     * @param   replacements  DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    protected Map<String, String> getReports(final FilenameFilter filter, Map<String, String> replacements) {
        final Map<String, String> result = new HashMap<String, String>();

        if (replacements == null) {
            replacements = new HashMap<String, String>();
        }

        final String[] reports = sourceDirectory.list(filter);

        for (final String report : reports) {
            String output = report.substring(0, report.lastIndexOf(suffixReport)).concat(suffixTarget);

            for (final Map.Entry<String, String> replacement : replacements.entrySet()) {
                output = output.replaceAll(replacement.getKey(), replacement.getValue().replace("/", ""));
            }

            result.put(report, output);
        }

        return result;
    }

    /**
     * DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public Map<String, String> getReportsLevel1() {
        return getReports(filterLevel1, null);
    }

    /**
     * DOCUMENT ME!
     *
     * @param   replacements  DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public Map<String, String> getReportsLevel2(final Map<String, String> replacements) {
        return getReports(filterLevel2, replacements);
    }

    /**
     * DOCUMENT ME!
     *
     * @param   replacements  DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public Map<String, String> getReportsLevel3(final Map<String, String> replacements) {
        return getReports(filterLevel3, replacements);
    }

    /**
     * DOCUMENT ME!
     *
     * @param   replacements  DOCUMENT ME!
     *
     * @return  DOCUMENT ME!
     */
    public Map<String, String> getReportsLevel4(final Map<String, String> replacements) {
        return getReports(filterLevel4, replacements);
    }

    //~ Inner Classes ----------------------------------------------------------

    /**
     * DOCUMENT ME!
     *
     * @version  $Revision$, $Date$
     */
    private class WRRLReportFilter implements FilenameFilter {

        //~ Instance fields ----------------------------------------------------

        private String prefix;
        private String suffix;

        //~ Constructors -------------------------------------------------------

        /**
         * Creates a new WRRLReportFilter object.
         *
         * @param  prefix  DOCUMENT ME!
         * @param  suffix  DOCUMENT ME!
         */
        public WRRLReportFilter(final String prefix, final String suffix) {
            this.prefix = prefix;
            this.suffix = suffix;
        }

        //~ Methods ------------------------------------------------------------

        @Override
        public boolean accept(final File dir, final String name) {
            boolean result = false;

            if ((name == null) || (name.trim().length() <= 0)) {
                return result;
            }

            if (name.startsWith(prefix) && name.endsWith(suffix)) {
                result = true;
            }

            return result;
        }
    }
}
