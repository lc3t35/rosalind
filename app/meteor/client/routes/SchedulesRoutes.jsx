import React from 'react'
import { Route, IndexRoute } from 'react-router'
import Blaze from 'meteor/gadicc:blaze-react-component'
import { StatusBoardContainer } from 'client/ui/schedules/statusBoard/StatusBoardContainer'
import { RequestsContainer } from 'client/ui/schedules/requests/RequestsContainer'

export const SchedulesRoutes = () => (
  <Route path="schedules">
    <IndexRoute component={StatusBoardContainer} />
    <Route path="default" component={() => <Blaze template="schedulesDefault" />} />
    <Route path="override" component={() => <Blaze template="schedulesOverride" />} />
    <Route path="requests" component={RequestsContainer} />
    <Route path="businessHours" component={() => <Blaze template="businessHours" />} />
    <Route path="holidays" component={() => <Blaze template="holidays" />} />
    <Route path="default/:username" component={() => <Blaze template="schedulesDefault" />} />
  </Route>
)
