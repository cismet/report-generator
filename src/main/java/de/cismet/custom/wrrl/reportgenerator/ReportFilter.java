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

import java.io.File;
import java.io.FilenameFilter;

/**
 * DOCUMENT ME!
 *
 * @author   therter
 * @version  $Revision$, $Date$
 */
public class ReportFilter implements FilenameFilter {

    //~ Instance fields --------------------------------------------------------

    private String prefix;
    private String suffix;

    //~ Constructors -----------------------------------------------------------

    /**
     * Creates a new WRRLReportFilter object.
     *
     * @param  prefix  DOCUMENT ME!
     * @param  suffix  DOCUMENT ME!
     */
    public ReportFilter(final String prefix, final String suffix) {
        this.prefix = prefix;
        this.suffix = suffix;
    }

    //~ Methods ----------------------------------------------------------------

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
