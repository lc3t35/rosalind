import React from 'react'
import FlipMove from 'react-flip-move'
import moment from 'moment'
import { Button } from 'react-bootstrap'
import { TAPi18n } from 'meteor/tap:i18n'
import { weekOfYear } from 'util/time/format'
import { dayToDate } from 'util/time/day'
import { Icon } from 'client/ui/components/Icon'
import { DateNavigation } from 'client/ui/components/DateNavigation'
import { Box } from 'client/ui/components/Box'
import { Report } from './Report'

export class ReportsScreen extends React.Component {
  constructor (props) {
    super(props)
    this.handlePrint = this.handlePrint.bind(this)
    this.handleToggleRevenue = this.handleToggleRevenue.bind(this)

    this.state = {
      showRevenue: true
    }
  }

  handlePrint () {
    if (window.native) {
      console.log('[Client] Printing: native')
      const title = moment(dayToDate(this.props.day))
        .format("YYYY-MM-DD-[#{TAPi18n.__('reports.thisDaySingular')}]")
      window.native.print({ title })
    } else {
      console.log('[Client] Printing: default')
      window.print()
    }
  }

  handleToggleRevenue () {
    this.setState({
      ...this.state,
      showRevenue: !this.state.showRevenue
    })
  }

  render () {
    return (
      <div>
        <div className="content-header">
          <h1>
            {TAPi18n.__('reports.thisDaySingular')} {this.props.date.format(TAPi18n.__('time.dateFormatWeekday'))}&nbsp;
            <small>{weekOfYear(this.props.date)}</small>
          </h1>
          <DateNavigation date={this.props.date} basePath="reports" pullRight>
            <Button bsSize="small" onClick={this.handlePrint} title={TAPi18n.__('ui.print')}><Icon name="print" /></Button>
            <Button bsSize="small" onClick={this.handleToggleRevenue} title={TAPi18n.__('reports.showRevenue')}><Icon name="euro" /></Button>
          </DateNavigation>
        </div>
        <div className="content">
          <FlipMove duration={230}>
            {
              this.props.report
              ? <div key="reportTable"><Report report={this.props.report} showRevenue={this.state.showRevenue} /></div>
            : <div key="noReports"><Box type="warning" title={TAPi18n.__('ui.notice')} body={TAPi18n.__('reports.empty')} /></div>
            }
          </FlipMove>
        </div>
      </div>
    )
  }
}
